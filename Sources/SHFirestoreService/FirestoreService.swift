//
//  FirestoreService.swift
//  
//
//  Created by 양승현 on 4/19/24.
//

#if os(iOS)
import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

public final class FirestoreService: FirestoreServiceProtocol {
  public init() {}
  
  /// Reqeust responseDTOs from endpoint's specific CollectionReference
  ///   when endpoint's **FirestoreMethod** is get type.
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    if case .get = endpoint.method {
      return collectionRef.getDocuments()
        .tryMap { snapshots in
          try snapshots.documents.map { snapshot in
            try snapshot.data(as: D.self)
          }
        }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    return Fail(error: FirestoreServiceError.docuemntNotfound).eraseToAnyPublisher()
  }
  
  /// Reqeust a responseDTO from endpoint's specific DocuemntReference
  ///   when endpoint's **FirestoreMethod** is get type.
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<D, FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.docuemntNotfound).eraseToAnyPublisher()
    }
    if case .get = endpoint.method {
      return documentRef.getDocument()
        .tryMap { snapshot in
          try snapshot.data(as: D.self)
        }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    return Fail(error: FirestoreServiceError.docuemntNotfound).eraseToAnyPublisher()

  }
  
  /// Use this method from endpoint's specific DocumentReference
  ///   when endopint's **FirestoreMethod** is one of save, delete or update
  public func request(
    endpoint: any FirestoreEndopintable
  ) -> AnyPublisher<Void, FirestoreServiceError> {
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.docuemntNotfound).eraseToAnyPublisher()
    }
    
    if case .delete = endpoint.method {
      return documentRef.delete()
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    
    if [.save, .update].contains(endpoint.method) {
      guard let requestDTO = endpoint.requestDTO else {
        return Fail(error: FirestoreServiceError.invalidRequestDTO).eraseToAnyPublisher()
      }
      return documentRef
        .setData(from: requestDTO)
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
  }
  
  /// If there is only one or many query conditions, you should use **makeQuery** to create the Query from Endpoint's reference computed property.
  public func query<D, E>(
    endpoint: E,
    makeQuery: FirestoreQueryHandler
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard case .query = endpoint.method else {
      return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
    }
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    let query = makeQuery(collectionRef)
    return query.getDocuments()
      .tryMap { querySnapshot in
        try querySnapshot.documents.map { snapshot in
          try snapshot.data(as: D.self)
        }
      }
      .convertFirestoreServiceError()
      .eraseToAnyPublisher()

  }
}
#endif

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
  // MARK: - Properties
  public var queryForPagination: Query? = nil
  
  public init() {}
  
  /// Reqeust responseDTOs from endpoint's specific CollectionReference
  ///   when endpoint's **FirestoreMethod** is get type.
  /// If specific collection has no any document, it return empty array.
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
          if snapshots.isEmpty {
            return []
          }
          return try snapshots.documents.map { snapshot in
            try snapshot.data(as: D.self)
          }
        }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
  }
  
  /// Reqeust a responseDTO from endpoint's specific DocuemntReference
  ///   when endpoint's **FirestoreMethod** is get type.
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<D, FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
    }
    if case .get = endpoint.method {
      return documentRef.getDocument()
        .tryMap { snapshot in
          try snapshot.data(as: D.self)
        }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()

  }
  
  /// Use this method from endpoint's specific DocumentReference
  ///   when endopint's **FirestoreMethod** is one of delete or update
  public func request(
    endpoint: any FirestoreEndopintable
  ) -> AnyPublisher<Void, FirestoreServiceError> {
    if case .save(let documentId) = endpoint.method {
      guard let collectionRef = endpoint.reference as? CollectionReference else {
        return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
      }
      
      /// If request DTO is nil, it is assumed that only a document with no fields is created.
      guard let requestDTO = endpoint.requestDTO else {
        if let documentId {
          return collectionRef.document(documentId)
            .setData([:])
            .convertFirestoreServiceError()
            .eraseToAnyPublisher()
        } else {
          return collectionRef.addDocument(data: [:])
            .convertFirestoreServiceError()
            .map { _ -> () in return }
            .eraseToAnyPublisher()
        }
      }
      
      /// If FirestoreMethod save's associated value is exist, create a document with the document ID and save the requestDTO.
      if let documentId {
        return collectionRef.document(documentId)
          .setData(from: requestDTO)
          .convertFirestoreServiceError()
          .map { _ -> () in return }
          .eraseToAnyPublisher()
      }
      
      guard let requestDTO = endpoint.requestDTO else {
        return Fail(error: FirestoreServiceError.invalidRequestDTO).eraseToAnyPublisher()
      }
      
      return collectionRef.addDocument(from: requestDTO)
        .convertFirestoreServiceError()
        .map { _ -> () in return }
        .eraseToAnyPublisher()
    }
    
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
    }
    
    if case .delete = endpoint.method {
      return documentRef.delete()
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    
    if case .update = endpoint.method {
      guard let requestDTO = endpoint.requestDTO else {
        return Fail(error: FirestoreServiceError.invalidRequestDTO).eraseToAnyPublisher()
      }
      do {
        let requestDictionary = try requestDTO.toDictionary()
        return documentRef
          .updateData(requestDictionary)
          .convertFirestoreServiceError()
          .eraseToAnyPublisher()
      } catch {
        return Fail(error: FirestoreServiceError.encodingError(error)).eraseToAnyPublisher()
      }
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
  
  /// Retrieve a specific collectionReference's all document's ID.
  ///
  /// Notes:
  /// 1. Specify a collectionReference location in FirestoreAccessible.
  /// 2. Retrieve a list of document IDs within that collection, whether the fields exist or not.
  ///
  public func retrieveDocumentIDs<E>(
    endpoint: E
  ) -> AnyPublisher<E.ResponseDTO, FirestoreServiceError>
  where E : FirestoreEndopintable, E.ResponseDTO == [String] {
    guard case .retrieveDocumentIdList = endpoint.method else {
      return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
    }
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    return collectionRef.getDocuments()
      .map { snapshots in
        if snapshots.isEmpty { return [] }
        return snapshots.documents.map { documentSnapshot in documentSnapshot.documentID }
      }
      .convertFirestoreServiceError()
      .eraseToAnyPublisher()

  }
  
  /// Notes:
  /// 1. If this is your first call to pagination, isFirstPagination must be set to true. And then for future paging except for the first call, isFirstPagination must be changed to false.
  /// You must specify limits before querying in makeQuery. You also need to specify the query you want in this closure.
  ///
  /// Example make query :
  /// ```
  /// service.paginate(
  ///   endpoint: ( specific FirestoreEndopintable instance ),
  ///   makeQuery: { collectionRef in // This specified collectionReference is your endpoint's reference.
  ///     return collectionRef
  ///       .order(by: "population") // This is key point
  ///       .limit(to: 10) // This is key point
  ///   }
  /// ```
  public func paginate<D, E>(
    endpoint: E,
    makeQuery: @escaping FirestoreQueryForPaginationHandler,
    isFirstPagination: Bool = true
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard case .query = endpoint.method else {
      return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
    }
    
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    
    let hasNoMorePage = queryForPagination == nil
    
    if isFirstPagination {
      queryForPagination = makeQuery(collectionRef)
    } else if hasNoMorePage {
      return Fail(error: FirestoreServiceError.noMorePage).eraseToAnyPublisher()
    }
    
    return Future { [weak self] promise in
      self?.queryForPagination?
        .getDocuments { snapshot, error in
          guard let snapshot else {
            promise(.failure(.failToRetrievingCollection(error)))
            return
          }
          
          if snapshot.isEmpty {
            self?.queryForPagination = nil
            promise(.failure(.noMorePage))
            return
          }
          
          guard let lastDocument = snapshot.documents.last else {
            self?.queryForPagination = nil
            promise(.failure(.noMorePage))
            return
          }
          
          /// Next query
          self?.queryForPagination = makeQuery(collectionRef)
            .start(afterDocument: lastDocument)
          
          do {
            let responseDTO = try snapshot.documents.map { documentSnapshot in
              try documentSnapshot.data(as: D.self)
            }
            promise(.success(responseDTO))
          } catch {
            promise(.failure(FirestoreServiceError.decodingError(error)))
          }
        }
    }.eraseToAnyPublisher()
  }
}
#endif

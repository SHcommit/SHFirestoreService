//
//  FirestoreService.swift
//  
//
//  Created by 양승현 on 4/19/24.
//

#if os(iOS)
import Combine
import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

public final class FirestoreService {
  // MARK: - Dependencies
  private let backgroundQueue: DispatchQueue
  
  // MARK: - Properties
  public var queryForPagination: Query? = nil
  
  // MARK: - Lifecycle
  public init(backgroundQueue: DispatchQueue = .global(qos: .default)) {
    self.backgroundQueue = backgroundQueue
  }
}

extension FirestoreService: FirestoreServiceProtocol {
  /// Notes:
  /// 1. Reqeust responseDTOs from endpoint's specific CollectionReference
  ///   when endpoint's **FirestoreMethod** is get type.
  /// 2. If specific collection has no any document, it return empty array.
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    if case .get = endpoint.method {
      return collectionRef.getDocuments()
        .subscribe(on: backgroundQueue)
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
  
  /// Notes:
  /// Reqeust a responseDTO from endpoint's specific DocuemntReference when endpoint's **FirestoreMethod** is get type.
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<D, FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
    }
    if case .get = endpoint.method {
      return documentRef.getDocument()
        .subscribe(on: backgroundQueue)
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
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
    }
    
    if case .delete = endpoint.method {
      return documentRef.delete()
        .subscribe(on: backgroundQueue)
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
          .subscribe(on: backgroundQueue)
          .convertFirestoreServiceError()
          .eraseToAnyPublisher()
      } catch {
        return Fail(error: FirestoreServiceError.encodingError(error)).eraseToAnyPublisher()
      }
    }
    return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
  }
  
  /// Save a document using endpoint. And the ID of the created document A is returned.
  ///
  /// Notes:
  /// 1. If requestDTO is nil, only the document is created without any fields.
  ///   The same applies if you set the document ID or give the document ID through firesotre's automatic document.
  /// 2. If there is a response DTO at the endpoint,
  ///   fields and values ​​are formed through the key values ​​defined in CodingKeys through encode(to:) of the encodable.
  ///
  ///   Depending on whether there is a specific ID or not, a document with a specified documentId or an automatic ID is created.
  public func saveDocument(
    endpoint: any FirestoreEndopintable
  ) -> AnyPublisher<FirestoreServiceProtocol.DocumentID, FirestoreServiceError> {
    guard case .save(let documentId) = endpoint.method else {
      return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
    }
    
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    
    /// If request DTO is nil, it is assumed that only a document with no fields is created.
    guard let requestDTO = endpoint.requestDTO else {
      if let documentId {
        return collectionRef
          .document(documentId)
          .setData([:])
          .subscribe(on: backgroundQueue)
          .convertFirestoreServiceError()
          .map { _ in  return documentId }
          .eraseToAnyPublisher()
      } else {
        return collectionRef
          .addDocument(data: [:])
          .subscribe(on: backgroundQueue)
          .map { $0.documentID }
          .convertFirestoreServiceError()
          .eraseToAnyPublisher()
      }
    }
    
    if let documentId {
      return collectionRef
        .document(documentId)
        .setData(from: requestDTO)
        .subscribe(on: backgroundQueue)
        .map { _ in return documentId }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    
    /// If the document ID is not specified, the document is created using Firestore's automatic document ID assignment.
    return collectionRef
      .addDocument(from: requestDTO)
      .subscribe(on: backgroundQueue)
      .map { $0.documentID }
      .convertFirestoreServiceError()
      .eraseToAnyPublisher()
  }
  
  /// Notes:
  /// If there is only one or many query conditions,
  ///   you should use **makeQuery** to create the Query from Endpoint's reference computed property.
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
      .subscribe(on: backgroundQueue)
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
      .subscribe(on: backgroundQueue)
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

// MARK: - FirestoreTransactional
extension FirestoreService: FirestoreTransactional {
  public func performTransaction(
    _ updateBlock: @escaping (Transaction) throws -> Any?
  ) -> AnyPublisher<Any?, any Error> {
    return Firestore.firestore()
      .runTransaction(updateBlock)
      .mapError { error in
        return FirestoreServiceError.failedTransaction(error)
      }.eraseToAnyPublisher()
  }
}
#endif

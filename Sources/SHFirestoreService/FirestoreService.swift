//
//  FirestoreService.swift
//  
//
//  Created by 양승현 on 4/19/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

#if os(iOS) && canImport(Combine) && swift(>=5.0)
import Combine

@available(swift 5.0)
@available(iOS 13.0, *)

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

// MARK: - FirestoreServiceProtocol
extension FirestoreService: FirestoreServiceProtocol {
  /// Notes:
  /// 1. Reqeust responseDTOs from endpoint's specific CollectionReference
  ///   when endpoint's **FirestoreMethod** is get type.
  /// 2. If specific collection has no any document, it return empty array.
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where E: FirestoreEndopintable,
        E.ResponseDTO: Collection,
        E.ResponseDTO.Element == D,
        D: Decodable {
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    if case .get = endpoint.method {
      return collectionRef.getDocuments()
        .subscribeAndReceive(on: backgroundQueue)
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
  
  /// Reqeust for response a D type's responseDTO.
  ///
  /// Notes:
  /// 1. Reqeust a responseDTO from endpoint's specific DocuemntReference adapting FirestoreAccessible
  ///     when endpoint's **FirestoreMethod** is get type.
  /// 2. Request for the number of all documents from endpoint's specific CollectionReference adapting FirestoreAccessible
  ///     when endpoint's **FirestoreMethod** is retrieveNumberOfDocuments type.
  ///     - This logic using AggrateQuery's count() that match between 0 and 1000 index entries billed for one documen read: ]
  ///     - https://firebase.google.com/docs/firestore/query-data/aggregation-queries
  public func request<D, E>(
    endpoint: E
  ) -> AnyPublisher<D, FirestoreServiceError>
  where D == E.ResponseDTO, E : FirestoreEndopintable {
    if case .get = endpoint.method {
      guard let documentRef = endpoint.reference as? DocumentReference else {
        return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
      }
      return documentRef.getDocument()
        .subscribeAndReceive(on: backgroundQueue)
        .tryMap { snapshot in
          try snapshot.data(as: D.self)
        }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    if D.self == Int.self {
      guard let collectionRef = endpoint.reference as? CollectionReference else {
        return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
      }
      if case .retrieveNumberOfDocuments = endpoint.method {
        let query = collectionRef.count
        return query.getAggregateQuery(source: .server)
          .subscribeAndReceive(on: backgroundQueue)
          .convertFirestoreServiceError()
          .map { ($0?.count ?? 0) as! D }
          .eraseToAnyPublisher()
      }
    }
    return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
  }
  
  /// Use this method from endpoint's specific DocumentReference
  ///   when endopint's **FirestoreMethod** is one of delete, update or deleteACollection
  public func request(
    endpoint: any FirestoreEndopintable
  ) -> AnyPublisher<Void, FirestoreServiceError> {
    if case .deleteACollection = endpoint.method {
      guard let collectionRef = endpoint.reference as? CollectionReference else {
        return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
      }
      
      return collectionRef.getDocuments()
        .subscribeAndReceive(on: backgroundQueue)
        .mapError { error in
          FirestoreServiceError.documentsNotFound(error)
        }.map { snapshot in
          let batch = Firestore.firestore().batch()
          snapshot.documents.forEach { batch.deleteDocument($0.reference) }
          return batch
        }
        .commit()
        .eraseToAnyPublisher()
    }
    
    guard let documentRef = endpoint.reference as? DocumentReference else {
      return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
    }
    
    if case .delete = endpoint.method {
      return documentRef.delete()
        .subscribeAndReceive(on: backgroundQueue)
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    
    if case .update = endpoint.method {
      guard let requestDTO = endpoint.requestDTO else {
        if let requestDTODictionary = endpoint.requestDTODictionary {
          return documentRef
            .updateData(requestDTODictionary)
            .subscribeAndReceive(on: backgroundQueue)
            .convertFirestoreServiceError()
            .eraseToAnyPublisher()
        }
        return Fail(error: FirestoreServiceError.invalidRequestDTO).eraseToAnyPublisher()
      }
      do {
        let requestDictionary = try requestDTO.toDictionary()
        return documentRef
          .updateData(requestDictionary)
          .subscribeAndReceive(on: backgroundQueue)
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
  /// 1. If requestDTO and requestDTODictionary are nil, only the document is created without any fields.
  ///   The same applies if you set the document ID or give the document ID through firesotre's automatic document.
  /// 2. If a respose dto dictionary is exist at the endpoint,
  ///   It is saved in the document If documentId exists, the ID of the document is specified, otherwise it is automatically generated.
  /// 3. If there is a response DTO at the endpoint,
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
    
    if let requestDTODictionary = endpoint.requestDTODictionary {
      if let documentId {
        return collectionRef
          .document(documentId)
          .setData(requestDTODictionary)
          .subscribeAndReceive(on: backgroundQueue)
          .convertFirestoreServiceError()
          .map { _ in return documentId }
          .eraseToAnyPublisher()
      } else {
        return collectionRef
          .addDocument(data: requestDTODictionary)
          .subscribeAndReceive(on: backgroundQueue)
          .map { $0.documentID }
          .convertFirestoreServiceError()
          .eraseToAnyPublisher()
      }
    }
    
    /// If request DTO and requestDTODictionary are nil it is assumed that only a document with no fields is created.
    guard let requestDTO = endpoint.requestDTO else {
      if let documentId {
        return collectionRef
          .document(documentId)
          .setData([:])
          .subscribeAndReceive(on: backgroundQueue)
          .convertFirestoreServiceError()
          .map { _ in  return documentId }
          .eraseToAnyPublisher()
      } else {
        return collectionRef
          .addDocument(data: [:])
          .subscribeAndReceive(on: backgroundQueue)
          .map { $0.documentID }
          .convertFirestoreServiceError()
          .eraseToAnyPublisher()
      }
    }
    
    if let documentId {
      return collectionRef
        .document(documentId)
        .setData(from: requestDTO)
        .subscribeAndReceive(on: backgroundQueue)
        .map { _ in return documentId }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    }
    
    /// If the document ID is not specified, the document is created using Firestore's automatic document ID assignment.
    return collectionRef
      .addDocument(from: requestDTO)
      .subscribeAndReceive(on: backgroundQueue)
      .map { $0.documentID }
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
  where E: FirestoreEndopintable, E.ResponseDTO == [String] {
    guard case .retrieveDocumentIdList = endpoint.method else {
      return Fail(error: FirestoreServiceError.invalidFirestoreMethodRequest).eraseToAnyPublisher()
    }
    guard let collectionRef = endpoint.reference as? CollectionReference else {
      return Fail(error: FirestoreServiceError.collectionNotFound).eraseToAnyPublisher()
    }
    return collectionRef.getDocuments()
      .subscribeAndReceive(on: backgroundQueue)
      .map { snapshots in
        if snapshots.isEmpty { return [] }
        return snapshots.documents.map { documentSnapshot in documentSnapshot.documentID }
      }
      .convertFirestoreServiceError()
      .eraseToAnyPublisher()
  }
}

// MARK: - FirestoreQueryable
extension FirestoreService: FirestoreQueryable {
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
    do {
      let query = try makeQuery(collectionRef)
      return query.getDocuments()
        .subscribeAndReceive(on: backgroundQueue)
        .tryMap { querySnapshot in
          try querySnapshot.documents.map { snapshot in
            try snapshot.data(as: D.self)
          }
        }
        .convertFirestoreServiceError()
        .eraseToAnyPublisher()
    } catch {
      return Fail(error: FirestoreServiceError.failedToMakeQuery(error)).eraseToAnyPublisher()
    }
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
  /// Notes:
  /// 1. Executes a transaction and emits FiresotreServiceError if execution fails.
  public func performTransaction(
    _ updateBlock: @escaping (Transaction) throws -> Any?
  ) -> AnyPublisher<Any?, any Error> {
    return Firestore.firestore()
      .runTransaction(updateBlock)
      .subscribeAndReceive(on: backgroundQueue)
      .mapError { error in
        return FirestoreServiceError.failedTransaction(error)
      }.eraseToAnyPublisher()
  }
}

// MARK: - FirestoreDocumentSupportable
extension FirestoreService: FirestoreDocumentSupportable {
  /// Determine whether a document exists
  ///
  /// Notes:
  /// 1. Do not need to specify FirestoreMethod's specific type when using this function.
  /// 2. Set up requestType of FirestoreAccessible in endpoint to access firestore's a specific document before call this function.
  /// 3. When a document path is provided from requestType, this function determines whether the document exists by querying the snapshot.
  public func isDocumentExists(
    endpoint: any FirestoreEndopintable
  ) -> AnyPublisher<Bool, FirestoreServiceError> {
    guard let documentRef = endpoint.reference.asDocumentRef else {
      return Fail(error: FirestoreServiceError.documentNotFound).eraseToAnyPublisher()
    }
    return documentRef
      .getDocument()
      .convertFirestoreServiceError()
      .map { snapshot -> Bool in return snapshot.exists }.eraseToAnyPublisher()
      .eraseToAnyPublisher()
  }
  
  /// Checks if a document is duplicated or not from the endpoint requestType is a collectionRef using firestore's query.
  ///
  /// Notes:
  /// 1. This method executes a Firestore query to check if the specified field in the document is duplicated from a collection reference.
  /// 2. endpoint's a documentRef computed property of requestType property  should return nil.
  /// 3. The query is executed using the provided endpoint and query handler.
  /// 4. The requestType of endpoint is not used.
  ///
  /// - Parameters:
  ///   - endpoint: The Firestore endpoint to query, which must conform to `FirestoreEndopintable`.
  ///   - query: The Firestore query handler used to execute the query.
  ///            The query should be designed to check for field duplication.
  /// - Returns: A publisher that emits a `Bool` indicating whether the field is duplicated (`true`) or not (`false`).
  /// - Throws: `FirestoreServiceError` if the query execution fails.
  ///
  /// Example:
  /// - Does a document with test1 exist in the user's collection?
  /// ```
  /// let editedUserName = "test1"
  /// let endpoint: FirestoreEndpointable = UserAPIEndpoint()
  /// FirestoreService().isFieldDuplicated(endpoint: endpoint) { collectionReference in
  ///   return collectionReference
  ///     .whereField("username", isEqualTo: editedUserName)
  /// }.receive(on: DispatchQueue.main)
  /// .map { isFieldDuplicated in
  ///   // TODO: - You can check whether the query has any matching documents in this downstream
  /// }
  /// ```
  public func isDocumentExists(
    endpoint: any FirestoreEndopintable,
    makeQuery: @escaping QueryHandler
  ) -> AnyPublisher<Bool, FirestoreServiceError> {
    return Future<Bool, FirestoreServiceError> { promise in
      do {
        let collectionRef = endpoint.requestType.collectionRef
        let query = try makeQuery(collectionRef)
        query.getDocuments { querySnapshot, error in
          if let error = error {
            promise(.failure(.wrappedfirestoreError(error)))
            return
          }
          if let documents = querySnapshot?.documents, !documents.isEmpty {
            promise(.success(true))
            return
          }
          promise(.success(false))
        }
      } catch {
        promise(.failure(.wrappedfirestoreError(error)))
      }
    }.eraseToAnyPublisher()
  }
}
#endif

//
//  FirestoreDocumentSupportable.swift
//  
//
//  Created by 양승현 on 5/16/24.
//

import Combine
import Foundation

#if os(iOS) && canImport(FirebaseFirestore)
import FirebaseFirestore
public protocol FirestoreDocumentSupportable {
  typealias QueryHandler = (CollectionReference) throws -> Query
  
  /// When implementing the endpoint's document instance to be returned from the request Type, it is returned whether the document exists.
  func isDocumentExists(
    endpoint: any FirestoreEndopintable
  ) -> AnyPublisher<Bool, FirestoreServiceError>
  
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
  func isDocumentExists(
    endpoint: any FirestoreEndopintable,
    makeQuery: @escaping QueryHandler
  ) -> AnyPublisher<Bool, FirestoreServiceError>
}
#endif

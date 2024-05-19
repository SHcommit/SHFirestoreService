//
//  FirestoreQueryable.swift
//
//
//  Created by 양승현 on 5/2/24.
//

import Combine
import Foundation
import FirebaseFirestore

#if os(iOS)
public protocol FirestoreQueryable {
  typealias FirestoreQueryHandler = (FirestoreReference) throws -> Query
  typealias FirestoreQueryForPaginationHandler = (CollectionReference) -> Query
  
  var queryForPagination: Query? { get }
  
  func query<D, E>(
    endpoint: E,
    makeQuery: FirestoreQueryHandler
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
  func paginate<D, E>(
    endpoint: E,
    makeQuery: @escaping FirestoreQueryForPaginationHandler,
    isFirstPagination: Bool
  ) -> AnyPublisher<[D], FirestoreServiceError>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
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
  func isFieldDuplicated(
    endpoint: any FirestoreEndopintable,
    makeQuery: FirestoreQueryHandler
  ) -> AnyPublisher<Bool, FirestoreServiceError>
}
#endif

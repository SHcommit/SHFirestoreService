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
  
  /// Check if a document is duplicated or not from the endpoint requestType is a collectionRef using firestore's query.
  func isFieldDuplicated(
    endpoint: any FirestoreEndopintable,
    from query: FirestoreQueryHandler
  ) -> AnyPublisher<Bool, FirestoreServiceError>
}
#endif

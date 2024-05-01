//
//  FirestoreServiceProtocol.swift
//
//
//  Created by 양승현 on 4/19/24.
//
#if os(iOS)
import Foundation
import Combine
import FirebaseFirestore

public protocol FirestoreServiceProtocol {
  // MARK: - Constants
  typealias FirestoreQueryHandler = (FirestoreReference) -> Query
  typealias FirestoreQueryForPaginationHandler = (CollectionReference) -> Query
  typealias DocumentID = String
  
  // MARK: - Properties
  var queryForPagination: Query? { get }
  
  // MARK: - Helpers
  func request<D, E>(endpoint: E) -> AnyPublisher<[D], FirestoreServiceError>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
  func request<D, E>(endpoint: E) -> AnyPublisher<D, FirestoreServiceError>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
  
  /// Contains related logic when the endpoint's FiresotreMethod type is update or delete.
  func request(endpoint: any FirestoreEndopintable) -> AnyPublisher<Void, FirestoreServiceError>
  
  /// When the endpoint's FirestoreMethod type is save, the save logic is called in the specific collection path of the endpoint's FirestoreAccessible.
  func saveDocument(endpoint: any FirestoreEndopintable) -> AnyPublisher<DocumentID, FirestoreServiceError>
  
  func retrieveDocumentIDs<E>(endpoint: E) -> AnyPublisher<E.ResponseDTO, FirestoreServiceError>
  where E: FirestoreEndopintable,
        E.ResponseDTO == [String]
  
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
}
#endif

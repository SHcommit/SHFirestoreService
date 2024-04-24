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
  
  // MARK: - Helpers
  func request<D, E>(endpoint: E) -> AnyPublisher<[D], Error>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
  func request<D, E>(endpoint: E) -> AnyPublisher<D, Error>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
  func request(endpoint: any FirestoreEndopintable) -> AnyPublisher<Void, Error>
  
  func query<D, E>(
    endpoint: E,
    makeQuery: FirestoreQueryHandler
  ) -> AnyPublisher<[D], Error>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
}
#endif

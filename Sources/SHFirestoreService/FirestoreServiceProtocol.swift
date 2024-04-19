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
    makeQuery: any FirestoreQueryMakeable,
    additionalQueries: [any FirestoreQueryAppendable]
  ) -> AnyPublisher<[D], Error>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
}

// MARK: - Helpers
public extension FirestoreServiceProtocol {
  func appendQueries(_ query: Query, queries: [any FirestoreQueryAppendable]) {
    if !queries.isEmpty {
      queries.forEach { $0.apply(to: query) }
    }
  }
}
#endif

//
//  FirestoreQuery.swift
//
//
//  Created by 양승현 on 4/19/24.
//
#if os(iOS)
import Foundation
import FirebaseFirestore

public protocol FirestoreQuery {
  associatedtype Value: Any
  var field: String { get }
  var value: Value { get }
}

public protocol FirestoreQueryAppendable: FirestoreQuery {
  func apply(to query: Query)
}

public protocol FirestoreQueryMakeable: FirestoreQuery {
  func makeQuery(with reference: CollectionReference) -> Query
}
#endif

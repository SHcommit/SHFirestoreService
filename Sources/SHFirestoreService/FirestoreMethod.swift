//
//  FirestoreMethod.swift
//
//
//  Created by 양승현 on 4/19/24.
//
#if os(iOS)
import Foundation
import FirebaseFirestore

@frozen public enum FirestoreMethod {
  public typealias DocumentId = String
  case get
  /// If you want to specify the document name directly, just enter the associate value.
  case save(DocumentId?)
  case delete
  case update
  case query
}
#endif

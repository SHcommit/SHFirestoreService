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
  case get
  case save
  case delete
  case update
  case query
}
#endif

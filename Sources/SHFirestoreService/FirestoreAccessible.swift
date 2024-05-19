//
//  FirestoreAccessible.swift
//
//
//  Created by 양승현 on 4/19/24.
//

#if os(iOS)
import Foundation
import FirebaseFirestore

/// This protocol defines objects that can access Firestore.
public protocol FirestoreAccessible {
  var collectionRef: CollectionReference { get }
  var documentRef: DocumentReference? { get }
}

// MARK: - Helpers
public extension FirestoreAccessible {
  var asCollectionRef: CollectionReference? {
    return self as? CollectionReference
  }
  
  var asDocumentRef: DocumentReference? {
    return self as? DocumentReference
  }
}
#endif

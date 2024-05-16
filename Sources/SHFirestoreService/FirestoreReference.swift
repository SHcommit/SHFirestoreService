//
//  FirestoreReference.swift
//
//
//  Created by 양승현 on 4/19/24.
//

#if os(iOS)
import FirebaseFirestore

public protocol FirestoreReference { }
extension DocumentReference: FirestoreReference { }
extension CollectionReference: FirestoreReference { }

// MARK: - Helpers
extension FirestoreReference {
  var asCollectionRef: CollectionReference? {
    return self as? CollectionReference
  }
  
  var asDocumentRef: DocumentReference? {
    return self as? DocumentReference
  }
}
#endif

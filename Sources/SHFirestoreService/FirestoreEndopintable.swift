//
//  FirestoreEndopintable.swift
//
//
//  Created by 양승현 on 4/19/24.
//
#if os(iOS)
import Foundation
import FirebaseFirestore

public protocol FirestoreEndopintable {
  associatedtype ResponseDTO: Decodable
  
  var requestDTO: (any Encodable)? { get }
  
  /// Firestore's service accesses and works on a collection, a docuemnt or docuemnts based on the FirestoreMethod.
  /// So, you need to assign the desired request from FirestoreService to what is required by FirestoreMethod.
  var method: FirestoreMethod { get }
  
  /// In order to access a specific collection or document in firestore, you must comply with Firestore DataLocationable.
  /// If you want to access the collection, docuemntRef must return nil.
  /// Otherwise, if you need to access the document, you need to inject the document's parent collection ref and the DocuemntRef of the desired document.
  /// As an example, it can be easily accessed through the FirestoreRequestType enum that conforms to FirestoreDataLocationable.
  var requestType: FirestoreAccessible { get }
}

public extension FirestoreEndopintable {
  var firestore: Firestore {
    Firestore.firestore()
  }
  
  /// If a DocumentRef does not exist, it is considered to utilize a request on the collection endpoint.
  var reference: FirestoreReference {
    guard let documentRef = requestType.documentRef else {
      return requestType.collectionRef
    }
    return documentRef
  }
}
#endif

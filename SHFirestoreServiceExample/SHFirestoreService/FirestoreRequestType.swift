//
//  FirestoreRequestType.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import FirebaseFirestore
import SHFirestoreService

/// Here, you can easily specify and manage the document path or collection path of a specific case by using a specific case and associatedValue.
@frozen enum FirestoreRequestType: FirestoreAccessible {
  case users(UsersRequest)
  
  private var collectionPath: String {
    switch self {
    case .users:
      "Users"
    }
  }
  
  // MARK: - FirestoreDataLocationable
  var collectionRef: CollectionReference {
    return Firestore.firestore().collection(collectionPath)
  }
  
  var documentRef: DocumentReference? {
    switch self {
    case .users(let requestType):
      guard let documentPath = requestType.documentPath else { return nil }
      return collectionRef.document(documentPath)
    }
  }
}

// MARK: - UsersRequest
extension FirestoreRequestType {
  @frozen enum UsersRequest {
    typealias UID = String
    case saveOwnerInfo(UID)
    
    var documentPath: String? {
      switch self {
      case .saveOwnerInfo(let uID):
        uID
      }
    }
  }
}

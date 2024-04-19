//
//  FirestoreEndpoint.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SHFirestoreService

final class FirestoreEndpoint<ResponseDTO>: FirestoreEndopintable
where ResponseDTO: Decodable {
  // MARK: - Properties
  var requestDTO: (any Encodable)?
  
  /// Firestore's service accesses and works on a collection, a docuemnt or docuemnts based on the FirestoreMethod.
  /// So, you need to assign the desired request from FirestoreService to what is required by FirestoreMethod.
  var method: FirestoreMethod
  
  /// In order to access a specific collection or document in firestore, you must comply with Firestore DataLocationable.
  /// If you want to access the collection, docuemntRef must return nil.
  /// Otherwise, if you need to access the document, you need to inject the document's parent collection ref and the DocuemntRef of the desired document.
  /// As an example, it can be easily accessed through the FirestoreRequestType enum that conforms to FirestoreDataLocationable.
  var requestType: any FirestoreAccessible
  
  // MARK: - Lifecycle
  init(
    requestDTO: (any Encodable)? = nil,
    method: FirestoreMethod,
    requestType: FirestoreRequestType
  ) {
    self.requestDTO = requestDTO
    self.method = method
    self.requestType = requestType
  }
}

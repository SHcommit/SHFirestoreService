//
//  FirestoreDocumentSupportable.swift
//  
//
//  Created by 양승현 on 5/16/24.
//

import Combine
import Foundation

public protocol FirestoreDocumentSupportable {
  func isDocumentExists(endpoint: any FirestoreEndopintable) -> AnyPublisher<Bool, FirestoreServiceError>
}

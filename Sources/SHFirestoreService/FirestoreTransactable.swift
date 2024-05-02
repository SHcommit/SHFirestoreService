//
//  FirestoreTransactable.swift
//
//
//  Created by 양승현 on 5/2/24.
//

import Combine
import Foundation
import FirebaseFirestore

#if os(iOS)
public protocol FirestoreTransactable {
  func performTransaction(
    _ updateBlock: @escaping (Transaction) throws -> Any?
  ) -> AnyPublisher<Any?, Error>
}
#endif

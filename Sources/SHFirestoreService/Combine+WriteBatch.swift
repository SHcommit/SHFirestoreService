//
//  Publisher+WriteBatch.swift
//
//
//  Created by 양승현 on 5/8/24.
//

import Foundation
#if canImport(FirebaseFirestore) && canImport(FirebaseFirestoreCombineSwift) && canImport(Combine) && swift(>=5.0)
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

@available(swift 5.0)
@available(iOS 13.0, *)

extension Publisher where Output == WriteBatch, Failure == FirestoreServiceError {
  func commit() -> AnyPublisher<Void, Failure> {
    return self.flatMap { batch in
      return batch
        .commit()
        .mapError { FirestoreServiceError.failedToWriteBatchCommit($0) }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }
}
#endif

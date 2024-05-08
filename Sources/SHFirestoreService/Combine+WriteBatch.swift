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

public extension Publisher where Output == WriteBatch, Failure == FirestoreServiceError {
  
  /// This is an extension function used to commit WriteBatches.
  ///
  /// Notes:
  /// 1. Generate and return a WriteBatch from the upstream publihser's output value.
  /// 2. Perform to commit batch using tins func
  ///
  /// Examples:
  /// ```
  /// # using the batch and commit functions when deleting an entire document #
  /// let collectionRef = ... # Get CollectionReference..
  /// let subscription = collectionRef.getDocuments().map { snapshot in
  ///   let batch = Firestore.firestore().batch()
  ///   snapshot.documents.forEach { batch.deleteDocument($0.reference) }
  ///   return batch
  /// }
  /// .commit() # perform commit from upstream's a batch : ]
  ///           # downstream
  /// ```
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

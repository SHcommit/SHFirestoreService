//
//  Combine+Helpers.swift
//
//
//  Created by 양승현 on 5/8/24.
//

import Foundation

#if canImport(Combine) && os(iOS) && swift(>=5.0)
import Combine

@available(swift 5.0)
@available(iOS 13.0, *)

internal extension Publisher {
  func subscribeAndReceive(
    on queue: DispatchQueue
  ) -> Publishers.ReceiveOn<Publishers.SubscribeOn<Self, DispatchQueue>, DispatchQueue> {
    return self.subscribe(on: queue).receive(on: queue)
  }
}

internal extension Publisher where Failure == Error {
  func convertFirestoreServiceError(
  ) -> Publishers.MapError<Self, FirestoreServiceError> {
    return self.mapError { error in
      FirestoreServiceError.wrappedfirestoreError(error)
    }
  }
}

#endif

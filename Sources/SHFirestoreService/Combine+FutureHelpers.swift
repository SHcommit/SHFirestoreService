//
//  Publisher+FutureHelpers.swift
//
//
//  Created by 양승현 on 5/8/24.
//

import Foundation

#if canImport(Combine) && os(iOS) && swift(>=5.0)
import Combine

public extension Publisher
where Output == Void, Failure == FirestoreServiceError {
  func sink(promise: @escaping Future<Output, Error>.Promise) -> AnyCancellable {
    return sink { completion in
      if case .failure(let error) = completion {
        promise(.failure(error))
      }
    } receiveValue: { _ in
      promise(.success(()))
    }
  }
  
  func sink(promise: @escaping Future<Output, Failure>.Promise) -> AnyCancellable {
    return sink { completion in
      if case .failure(let error) = completion {
        promise(.failure(error))
      }
    } receiveValue: { _ in
      promise(.success(()))
    }
  }
}

public extension Publisher
where Output == Void, Failure == Error {
  func sink(promise: @escaping Future<Output, Failure>.Promise) -> AnyCancellable {
    return sink { completion in
      if case .failure(let error) = completion {
        promise(.failure(error))
      }
    } receiveValue: { _ in
      promise(.success(()))
    }
  }
}
#endif

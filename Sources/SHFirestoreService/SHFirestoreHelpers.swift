//
//  File.swift
//  
//
//  Created by 양승현 on 4/24/24.
//

import Foundation
import Combine

internal extension Publisher where Failure == Error {
  func convertFirestoreServiceError(
  ) -> Publishers.MapError<Self, FirestoreServiceError> {
    return self.mapError { error in
      FirestoreServiceError.wrappedfirestoreError(error)
    }
  }
}

internal extension Encodable {
  func toDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw Swift.EncodingError.invalidValue(
        self,
        Swift.EncodingError.Context.init(
          codingPath: [],
          debugDescription: "Failed to convert encoded data to dictionary"))
    }
    return dict
  }
}

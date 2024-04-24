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

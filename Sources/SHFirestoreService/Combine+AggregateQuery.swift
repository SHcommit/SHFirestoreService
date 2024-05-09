//
//  Combine+AggregateQuery.swift
//
//
//  Created by 양승현 on 5/9/24.
//

import Foundation

#if canImport(FirebaseFirestore) && canImport(FirebaseFirestoreCombineSwift) && canImport(Combine) && swift(>=5.0)
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

@available(swift 5.0)
@available(iOS 13.0, *)

public extension AggregateQuery {
  func getAggregateQuery(source: AggregateSource) -> Future<AggregateQuerySnapshot?, Error> {
    return Future { promise in
      self.getAggregation(source: source) { snapshot, error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(snapshot))
        }
      }
    }
  }
}
#endif

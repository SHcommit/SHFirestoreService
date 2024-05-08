//
//  File.swift
//  
//
//  Created by 양승현 on 4/24/24.
//

#if os(iOS) && swift(>=5.0)
import Foundation

@available(swift 5.0)
@available(iOS 13.0, *)

internal extension Encodable {
  typealias Dictionary = [String: Any]
  func toDictionary() throws -> Dictionary {
    let data = try JSONEncoder().encode(self)
    guard let dict = try JSONSerialization.jsonObject(with: data) as? Dictionary else {
      throw Swift.EncodingError.invalidValue(
        self,
        Swift.EncodingError.Context.init(
          codingPath: [],
          debugDescription: "Failed to convert encoded data to dictionary"))
    }
    return dict
  }
}

#endif

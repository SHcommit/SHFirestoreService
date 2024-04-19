//
//  FirestoreUserEndpoint.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

struct OwnerInfoRequestDTO: Encodable {
  let name: String
}

/// Not use when save event occured.
struct VoidResponseDTO: Decodable { }

struct FirestoreUserEndpoint {
  static func saveOwnerInfo(
    with requestDTO: OwnerInfoRequestDTO,
    userUID: String
  ) -> FirestoreEndpoint<VoidResponseDTO> {
    return FirestoreEndpoint(
      requestDTO: requestDTO,
      method: .save,
      requestType: .users(.saveOwnerInfo(userUID)))
  }
}

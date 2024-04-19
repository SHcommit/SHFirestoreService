//
//  FirestoreUserRepository.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import SHFirestoreService

final class FirestoreUserRepository: UserRepository {
  private typealias Endpoint = FirestoreUserEndpoint
  private let service: FirestoreServiceProtocol
  
  init(service: FirestoreServiceProtocol) {
    self.service = service
  }
  
  func saveOwnerInfo(user: UserEntity, uID: String) -> AnyPublisher<Void, any Error> {
    let requestDTO = OwnerInfoRequestDTO(name: user.name)
    let endpoint = Endpoint.saveOwnerInfo(with: requestDTO, userUID: uID)
    return service.request(endpoint: endpoint)
      .eraseToAnyPublisher()
  }
}

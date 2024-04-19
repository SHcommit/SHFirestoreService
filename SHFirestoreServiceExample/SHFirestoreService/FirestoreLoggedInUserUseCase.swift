//
//  FirestoreLoggedInUserUseCase.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/20/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Combine

final class FirestoreLoggedInUserUseCase: LoggedInUserUseCase {
  // MARK: - Dependencies
  private let repository: UserRepository
  private let backgroundQueue: DispatchQueue
  
  // MARK: - Lifecycle
  init(
    repository: UserRepository,
    backgroundQueue: DispatchQueue = .global(qos: .userInitiated)
  ) {
    self.repository = repository
    self.backgroundQueue = backgroundQueue
  }
  
  // MARK: - Helpers
  func saveOwnerInfo(
    user: UserEntity,
    uID: String
  ) -> AnyPublisher<Void, any Error> {
    return repository
      .saveOwnerInfo(user: user, uID: uID)
      .subscribe(on: backgroundQueue)
      .eraseToAnyPublisher()
  }
}

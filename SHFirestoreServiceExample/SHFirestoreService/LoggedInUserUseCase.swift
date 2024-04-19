//
//  UserUseCase.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/20/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Combine

protocol LoggedInUserUseCase {
  func saveOwnerInfo(user: UserEntity, uID: String) -> AnyPublisher<Void, Error>
}

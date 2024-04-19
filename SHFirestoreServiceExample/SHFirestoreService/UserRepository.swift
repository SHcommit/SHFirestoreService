//
//  UserRepository.swift
//  SHFirestoreService_Example
//
//  Created by 양승현 on 4/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Combine

protocol UserRepository {
  func saveOwnerInfo(name: String, uID: String) -> AnyPublisher<Void, Error>
}

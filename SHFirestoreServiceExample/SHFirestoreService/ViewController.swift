//
//  ViewController.swift
//  SHFirestoreService
//
//  Created by SHcommit on 04/19/2024.
//  Copyright (c) 2024 SHcommit. All rights reserved.
//

import UIKit
import SHFirestoreService
import Combine

class ViewController: UIViewController {
  // MARK: - Properties
  private let loggedInUserUseCase: LoggedInUserUseCase = {
    let service = FirestoreService()
    let repository = FirestoreUserRepository(service: service)
    let useCase = FirestoreLoggedInUserUseCase(repository: repository)
    return useCase
  }()
  
  private var subscription: AnyCancellable?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// In the example, roles between layers are not thoroughly separated. Thank you for watching the flow of action.
    
    /// The situation now is, let's say we have a Users document in the root collection in Firestore
    ///   and there is a name field inside it. And the logic is to save the user's info through the document ID.
    ///
    /// Firestore.firestore().collection("users").document(userId) This logic can be obtained through RequestType and Endpoint.
    /// After that, the logic is to save the user's info in the reference above based on FirestoreService in the repository object.

    /// This is the logic to save in Firestore when the user changes the name.
    let userUID = "1234"
    let userEntity = UserEntity(name: "kiwi")
    subscription = loggedInUserUseCase
      .saveOwnerInfo(user: userEntity, uID: userUID)
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          print("DEBUG: Unexpected Error Occured. :\(error.localizedDescription)")
        }
      }, receiveValue: { _ in
        print("DEBUG: Save Success in firestore.")
      })
  }
}

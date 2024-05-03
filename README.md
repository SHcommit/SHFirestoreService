# SHFirestoreService
<div style="display:flex;">
<img src="https://img.shields.io/badge/iOS-13.0+-blue.svg">
<img src="https://img.shields.io/badge/swift-F05138?style=flat&logo=swift&logoColor=white">
<img src="https://img.shields.io/badge/combine-F05138?style=flat&logo=swift&logoColor=white">
</div>

## Hello: ]
Thank you @yasuntimure for allowing me to implement the Firestore library using Combine by referring to the FirestoreService library.

This is @yasuntimure's repository( <a href="https://github.com/yasuntimure/FirestoreService">link</a> ) and blog( <a href="https://eyupyasuntimur.medium.com/elegant-firestore-management-in-swift-a-generic-service-approach-126530867da9">link</a> ) referenced when developing SHFirestoreService.


## Introduce 🤩
The goal is to make it easier to use Firestore's access functions through Combine. To access Firestore, you need a path or reference. This is managed by FirestoreEndpoint, and it helps you easily access Firebase by utilizing one of the functions of FirestoreServiceProtocol based on FirestoreEndpoint.

Users can define and use Firestore Collection and Document reference access by complying with FirestoreAccessible.

Previously, when developing using Firebase, I wrote overlapping request functions when accessing Firestore's Collection and Document. It was developed to manage these roles and responsibilities in one module.

## Usage
- An example can be found in SHFirestoreServiceExample.

### 1. Create Your RequestType object for access firestore adapting **FirestoreAccessible** protocol.
- If you adhere to the enum type, you can easily implement it to access the desired collection or document reference for each specific case.
- All collections and documents accessing Firestore can be managed here.
### 2. Create Your Endpoint class adapting **FirestoreEndpointable** protocol.
- When implementing a basic Endpoint, assign the enum type implemented above to requestType.
- If you specify the desired requestDTO, method, and requestType when creating this basic endpoint, Endopint can access the corresponding collectionReference or documentReference.
- At this time, please note that the function type called from FirestoreService is different depending on the method.
### 3. Call the FirestoreService's specific func with the endpoint instance you created as the func's endpoint parameter.

- If you call one of the FirestoreService functions, you will receive a value or an error. Internally, it accesses a specific file in Firestore to retrieve, save, and update desired documents or documents.


## Installation
SHCoordinator supports [Swift Package Manager](https://www.swift.org/package-manager/).


### [SPM]
 Add package dependency using xcode swiftPM
1. Xcode upper menu. 'File'
2. Find "Add Packages..." and click.
3. Search My Package repository with dependency rule(Up to Next Major Version)
> https://github.com/SHcommit/SHFirestoreService.git
4. Add Package

Finally, add `Import SHFirestoreService` to your source code.

### ~~[CocoaPods]~~
- I couldn't find a module in Firebase's CocoaPods that allows Firestore functions to be handled with Combine, so deployment with CocoaPods is currently impossible😭.

## Minimum Requirements
| SHFirestoreService       | Date         | Swift        | Platforms                           |
|------------|--------------|-------------|-----------------------------------------------|
| SHCoordinator 1.2.3  | May 3, 2024  | Swift 5.0   | iOS 13.0 |


## Author

@SHcommit, happysh_S2@naver.com

## License

SHFirestoreService is available under the MIT license. See the LICENSE file for more info.

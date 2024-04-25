//
//  FirestoreServiceError.swift
//
//
//  Created by 양승현 on 4/19/24.
//

#if os(iOS)
import Foundation

@frozen public enum FirestoreServiceError: LocalizedError {
  case collectionNotFound
  case docuemntNotfound
  case methodNotSupported
  case invalidFirestoreMethodRequest
  case invalidRequestDTO
  case wrappedfirestoreError(Error)
  case encodingError(Error)
  
  public var errorDescription: String? {
    switch self {
    case .collectionNotFound:
      return "The specified collection was not found."
    case .docuemntNotfound:
      return "The specified document was not found."
    case .methodNotSupported:
      return "The requested method is not supported."
    case .invalidFirestoreMethodRequest:
      return "The request method to Firestore is invalid."
    case .invalidRequestDTO:
      return "The requestDTO object is invalid."
    case .wrappedfirestoreError(let error):
      return "Firestore Error: \(error.localizedDescription)"
    case .encodingError(let error):
      return error.localizedDescription
    }
  }
}
#endif

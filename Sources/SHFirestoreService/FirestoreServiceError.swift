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
  case documentNotFound
  case methodNotSupported
  case invalidFirestoreMethodRequest
  case invalidRequestDTO
  case wrappedfirestoreError(Error)
  case encodingError(Error)
  case decodingError(Error)
  case failedTransaction(Error)
  case failedToMakeQuery(Error)
  
  /// when paging
  case noMorePage
  case failToRetrievingCollection(Error?)
  
  public var errorDescription: String? {
    switch self {
    case .collectionNotFound:
      return "The specified collection was not found."
    case .documentNotFound:
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
    case .decodingError(let error):
      return error.localizedDescription
    case .noMorePage:
      return "No more page"
    case .failToRetrievingCollection(let error):
      return "Fail to retrieving collection: \(error?.localizedDescription ?? "Unknown error")"
    case .failedTransaction(let error):
      return "Fail transaction: \(error.localizedDescription)"
    case .failedToMakeQuery(let error):
      return "Fail to make query :\(error.localizedDescription)"
    }
  }
}
#endif

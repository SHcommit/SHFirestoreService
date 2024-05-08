//
//  FirestoreMethod.swift
//
//
//  Created by 양승현 on 4/19/24.
//
#if os(iOS)
import Foundation
import FirebaseFirestore

@frozen public enum FirestoreMethod {
  public typealias DocumentId = String
  
  /// Get a list of document IDs in a specific collection.
  ///   At this time, the document ID of the document is retrieved regardless of whether there is no field for the document.
  case retrieveDocumentIdList
  
  /// Decodes the documents in a specific collection and returns the desired Decodable.
  /// However, even if a field in the document does not exist, decoding may result in an error indicating that the document cannot be found.
  case get
  
  /// If you want to specify the document name directly, just enter the associate value.
  case save(DocumentId?)
  case delete
  
  /// This must be specified when deleting all documents in a collection.
  case deleteACollection
  case update
  case query
}
#endif

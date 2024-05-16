//
//  FirestoreServiceProtocol.swift
//
//
//  Created by 양승현 on 4/19/24.
//
#if os(iOS)
import Foundation
import Combine
import FirebaseFirestore

public protocol FirestoreServiceProtocol: FirestoreTransactional, FirestoreQueryable, FirestoreDocumentSupportable {
  // MARK: - Constants
  typealias DocumentID = String
  
  // MARK: - Helpers
  func request<D, E>(endpoint: E) -> AnyPublisher<[D], FirestoreServiceError>
  where E: FirestoreEndopintable,
        E.ResponseDTO: Collection,
        E.ResponseDTO.Element == D,
        D: Decodable
  
  func request<D, E>(endpoint: E) -> AnyPublisher<D, FirestoreServiceError>
  where D: Decodable,
        E: FirestoreEndopintable,
        D == E.ResponseDTO
  
  /// Contains related logic when the endpoint's FiresotreMethod type is update or delete.
  func request(endpoint: any FirestoreEndopintable) -> AnyPublisher<Void, FirestoreServiceError>
  
  /// When the endpoint's FirestoreMethod type is save, the save logic is called in the specific collection path of the endpoint's FirestoreAccessible.
  func saveDocument(endpoint: any FirestoreEndopintable) -> AnyPublisher<DocumentID, FirestoreServiceError>
  
  func retrieveDocumentIDs<E>(endpoint: E) -> AnyPublisher<E.ResponseDTO, FirestoreServiceError>
  where E: FirestoreEndopintable,
        E.ResponseDTO == [String]
}
#endif

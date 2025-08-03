//
//  UserRepositoryProtocol.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - Domain Repository Protocol
protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [User]
    func fetchUser(by id: Int) async throws -> User
}

// MARK: - Domain Errors
enum DomainError: Error, Equatable {
    case networkError(String)
    case decodingError(String)
    case userNotFound
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .userNotFound:
            return "User not found"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}

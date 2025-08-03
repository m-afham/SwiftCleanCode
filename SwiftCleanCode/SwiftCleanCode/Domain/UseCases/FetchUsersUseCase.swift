//
//  FetchUsersUseCase.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - Use Case Protocol
protocol FetchUsersUseCaseProtocol {
    func execute() async throws -> [User]
}

// MARK: - Use Case Implementation
final class FetchUsersUseCase: FetchUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [User] {
        return try await repository.fetchUsers()
    }
}

// MARK: - Fetch Single User Use Case
protocol FetchUserUseCaseProtocol {
    func execute(userId: Int) async throws -> User
}

final class FetchUserUseCase: FetchUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(userId: Int) async throws -> User {
        return try await repository.fetchUser(by: userId)
    }
}

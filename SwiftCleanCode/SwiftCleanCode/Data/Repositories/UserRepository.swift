//
//  UserRepository.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - User Repository Implementation
final class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchUsers() async throws -> [User] {
        do {
            let userDTOs = try await networkService.request(
                UserEndpoint.fetchUsers,
                responseType: [UserDTO].self
            )
            return userDTOs.map { $0.toDomain() }
        } catch let networkError as NetworkError {
            throw mapNetworkErrorToDomainError(networkError)
        } catch {
            throw DomainError.unknown(error.localizedDescription)
        }
    }
    
    func fetchUser(by id: Int) async throws -> User {
        do {
            let userDTO = try await networkService.request(
                UserEndpoint.fetchUser(id: id),
                responseType: UserDTO.self
            )
            return userDTO.toDomain()
        } catch let networkError as NetworkError {
            throw mapNetworkErrorToDomainError(networkError)
        } catch {
            throw DomainError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    private func mapNetworkErrorToDomainError(_ networkError: NetworkError) -> DomainError {
        switch networkError {
        case .invalidURL, .invalidResponse:
            return .networkError("Invalid network request")
        case .serverError(let code):
            if code == 404 {
                return .userNotFound
            } else {
                return .networkError("Server error: \(code)")
            }
        case .decodingError(let message):
            return .decodingError(message)
        case .unknown(let message):
            return .unknown(message)
        }
    }
}

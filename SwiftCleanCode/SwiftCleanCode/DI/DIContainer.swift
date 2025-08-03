//
//  DIContainer.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - Dependency Injection Container
final class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // MARK: - Network Layer
    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    // MARK: - Repository Layer
    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(networkService: networkService)
    }()
    
    // MARK: - Use Cases
    func makeFetchUsersUseCase() -> FetchUsersUseCaseProtocol {
        return FetchUsersUseCase(repository: userRepository)
    }
    
    func makeFetchUserUseCase() -> FetchUserUseCaseProtocol {
        return FetchUserUseCase(repository: userRepository)
    }
    
    // MARK: - View Models
    @MainActor
    func makeUserListViewModel() -> UserListViewModel {
        return UserListViewModel(fetchUsersUseCase: makeFetchUsersUseCase())
    }
    
    @MainActor
    func makeUserDetailViewModel(userId: Int) -> UserDetailViewModel {
        return UserDetailViewModel(userId: userId, fetchUserUseCase: makeFetchUserUseCase())
    }
    
    @MainActor
    func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
        return UserDetailViewModel(user: user, fetchUserUseCase: makeFetchUserUseCase())
    }
}

// MARK: - Test Container
#if DEBUG
extension DIContainer {
    static func makeTestContainer(
        networkService: NetworkServiceProtocol? = nil,
        userRepository: UserRepositoryProtocol? = nil
    ) -> DIContainer {
        let container = DIContainer()
        
        if let networkService = networkService {
            container.networkService = networkService
        }
        
        if let userRepository = userRepository {
            container.userRepository = userRepository
        }
        
        return container
    }
    
    // Allow modification for testing
    func setNetworkService(_ service: NetworkServiceProtocol) {
        self.networkService = service
    }
    
    func setUserRepository(_ repository: UserRepositoryProtocol) {
        self.userRepository = repository
    }
}
#endif

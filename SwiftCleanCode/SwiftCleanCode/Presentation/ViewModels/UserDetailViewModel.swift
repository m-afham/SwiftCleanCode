//
//  UserDetailViewModel.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - User Detail View Model
@MainActor
final class UserDetailViewModel: ObservableObject {
    @Published var user: User?
    @Published var loadingState: LoadingState = .idle
    
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    private let userId: Int
    
    init(userId: Int, fetchUserUseCase: FetchUserUseCaseProtocol) {
        self.userId = userId
        self.fetchUserUseCase = fetchUserUseCase
    }
    
    convenience init(user: User, fetchUserUseCase: FetchUserUseCaseProtocol) {
        self.init(userId: user.id, fetchUserUseCase: fetchUserUseCase)
        self.user = user
        self.loadingState = .loaded
    }
    
    // MARK: - Public Methods
    func fetchUser() {
        Task {
            await loadUser()
        }
    }
    
    func refreshUser() {
        Task {
            await loadUser()
        }
    }
    
    // MARK: - Private Methods
    private func loadUser() async {
        loadingState = .loading
        
        do {
            let fetchedUser = try await fetchUserUseCase.execute(userId: userId)
            user = fetchedUser
            loadingState = .loaded
        } catch let error as DomainError {
            loadingState = .error(error.localizedDescription)
        } catch {
            loadingState = .error("An unexpected error occurred")
        }
    }
}

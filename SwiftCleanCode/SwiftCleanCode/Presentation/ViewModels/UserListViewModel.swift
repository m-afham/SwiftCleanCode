//
//  UserListViewModel.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation
import Combine

// MARK: - Loading State
enum LoadingState: Hashable {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - User List View Model
@MainActor
final class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var loadingState: LoadingState = .idle
    @Published var searchText: String = ""
    
    private let fetchUsersUseCase: FetchUsersUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Computed property for filtered users
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(fetchUsersUseCase: FetchUsersUseCaseProtocol) {
        self.fetchUsersUseCase = fetchUsersUseCase
        setupSearchDebouncing()
    }
    
    // MARK: - Public Methods
    func fetchUsers() {
        Task {
            await loadUsers()
        }
    }
    
    func refreshUsers() {
        Task {
            await loadUsers()
        }
    }
    
    // MARK: - Private Methods
    private func loadUsers() async {
        loadingState = .loading
        
        do {
            let fetchedUsers = try await fetchUsersUseCase.execute()
            users = fetchedUsers
            loadingState = .loaded
        } catch let error as DomainError {
            loadingState = .error(error.localizedDescription)
        } catch {
            loadingState = .error("An unexpected error occurred")
        }
    }
    
    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                // Trigger UI update for filtered results
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

//
//  UserListView.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel: UserListViewModel
    
    init(viewModel: UserListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                switch viewModel.loadingState {
                case .idle:
                    EmptyStateView(
                        title: "Welcome",
                        message: "Pull to refresh or tap the button to load users",
                        action: {
                            viewModel.fetchUsers()
                        }
                    )
                    
                case .loading:
                    LoadingView()
                    
                case .loaded:
                    if viewModel.filteredUsers.isEmpty && !viewModel.searchText.isEmpty {
                        EmptySearchResultsView(searchText: viewModel.searchText)
                    } else {
                        UserList(users: viewModel.filteredUsers)
                    }
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        retryAction: {
                            viewModel.fetchUsers()
                        }
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Users")
            .refreshable {
                viewModel.refreshUsers()
            }
            .onAppear {
                if viewModel.loadingState == .idle {
                    viewModel.fetchUsers()
                }
            }
        }
    }
}

// MARK: - User List Component
struct UserList: View {
    let users: [User]
    
    var body: some View {
        List(users) { user in
            NavigationLink(destination: UserDetailView(user: user)) {
                UserRowView(user: user)
            }
        }
    }
}

// MARK: - User Row Component
struct UserRowView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(user.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(user.email)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search users...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// MARK: - Loading View Component
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading users...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View Component
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View Component
struct EmptyStateView: View {
    let title: String
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Load Users") {
                action()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty Search Results View Component
struct EmptySearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("No users found for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
#Preview {
    UserListView(viewModel: DIContainer.shared.makeUserListViewModel())
}

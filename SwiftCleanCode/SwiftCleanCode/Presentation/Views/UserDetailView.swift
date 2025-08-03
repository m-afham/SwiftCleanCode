//
//  UserDetailView.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import SwiftUI

struct UserDetailView: View {
    @StateObject private var viewModel: UserDetailViewModel
    
    init(user: User) {
        let fetchUserUseCase = DIContainer.shared.makeFetchUserUseCase()
        self._viewModel = StateObject(wrappedValue: UserDetailViewModel(user: user, fetchUserUseCase: fetchUserUseCase))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let user = viewModel.user {
                    UserHeaderView(user: user)
                    UserContactView(user: user)
                    UserAddressView(address: user.address)
                    UserCompanyView(company: user.company)
                } else {
                    switch viewModel.loadingState {
                    case .loading:
                        LoadingView()
                    case .error(let message):
                        ErrorView(message: message) {
                            viewModel.fetchUser()
                        }
                    case .idle, .loaded:
                        EmptyView()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("User Details")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.refreshUser()
        }
    }
}

// MARK: - User Header Component
struct UserHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(user.name.prefix(1)))
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            Text(user.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }
}

// MARK: - User Contact Component
struct UserContactView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Contact Information", icon: "person.circle")
            
            ContactRowView(icon: "envelope", title: "Email", value: user.email)
            ContactRowView(icon: "phone", title: "Phone", value: user.phone)
            ContactRowView(icon: "globe", title: "Website", value: user.website)
        }
    }
}

// MARK: - User Address Component
struct UserAddressView: View {
    let address: Address
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Address", icon: "location.circle")
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(address.street), \(address.suite)")
                    .font(.body)
                Text("\(address.city), \(address.zipcode)")
                    .font(.body)
                Text("Coordinates: \(address.geo.lat), \(address.geo.lng)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

// MARK: - User Company Component
struct UserCompanyView: View {
    let company: Company
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Company", icon: "building.2.circle")
            
            VStack(alignment: .leading, spacing: 8) {
                Text(company.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(company.catchPhrase)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                
                Text(company.bs)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

// MARK: - Section Header Component
struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Contact Row Component
struct ContactRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        UserDetailView(user: User.mockUser)
    }
}

// MARK: - Mock Data for Preview
extension User {
    static var mockUser: User {
        User(
            id: 1,
            name: "John Doe",
            username: "johndoe",
            email: "john@example.com",
            phone: "+1-234-567-8900",
            website: "johndoe.com",
            company: Company(
                name: "Tech Corp",
                catchPhrase: "Innovative solutions",
                bs: "synergistic actionable"
            ),
            address: Address(
                street: "123 Main St",
                suite: "Apt 456",
                city: "New York",
                zipcode: "10001",
                geo: Geo(lat: "40.7128", lng: "-74.0060")
            )
        )
    }
}

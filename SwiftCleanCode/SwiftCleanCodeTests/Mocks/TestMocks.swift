//
//  TestMocks.swift
//  SwiftCleanCodeTests
//
//  Created by Afham on 04/08/2025.
//

import Foundation
@testable import SwiftCleanCode

// MARK: - Mock User Repository
final class MockUserRepository: UserRepositoryProtocol {
    var usersToReturn: [User]?
    var userToReturn: User?
    var errorToThrow: DomainError?
    
    var fetchUsersCalled = false
    var fetchUserCalled = false
    var fetchUserIdParameter: Int?
    
    func fetchUsers() async throws -> [User] {
        fetchUsersCalled = true
        
        if let error = errorToThrow {
            throw error
        }
        
        return usersToReturn ?? []
    }
    
    func fetchUser(by id: Int) async throws -> User {
        fetchUserCalled = true
        fetchUserIdParameter = id
        
        if let error = errorToThrow {
            throw error
        }
        
        guard let user = userToReturn else {
            throw DomainError.userNotFound
        }
        
        return user
    }
}

// MARK: - Mock Network Service
final class MockNetworkService: NetworkServiceProtocol {
    var dataToReturn: Any?
    var errorToThrow: NetworkError?
    var requestCalled = false
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        requestCalled = true
        
        if let error = errorToThrow {
            throw error
        }
        
        guard let data = dataToReturn else {
            throw NetworkError.unknown("No data to return")
        }
        
        if let typedData = data as? T {
            return typedData
        } else {
            throw NetworkError.decodingError("Type mismatch")
        }
    }
}

// MARK: - Mock URL Session
final class MockURLSession: URLSessionProtocol {
    var dataToReturn: (Data, URLResponse)?
    var errorToThrow: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = errorToThrow {
            throw error
        }
        
        guard let dataResponse = dataToReturn else {
            throw NetworkError.unknown("No data configured")
        }
        
        return dataResponse
    }
}

// MARK: - Mock Use Cases
final class MockFetchUsersUseCase: FetchUsersUseCaseProtocol {
    var usersToReturn: [User] = []
    var errorToThrow: DomainError?
    var executeCalled = false
    
    func execute() async throws -> [User] {
        executeCalled = true
        
        if let error = errorToThrow {
            throw error
        }
        
        return usersToReturn
    }
}

final class MockFetchUserUseCase: FetchUserUseCaseProtocol {
    var userToReturn: User?
    var errorToThrow: DomainError?
    var executeCalled = false
    var userIdParameter: Int?
    
    func execute(userId: Int) async throws -> User {
        executeCalled = true
        userIdParameter = userId
        
        if let error = errorToThrow {
            throw error
        }
        
        guard let user = userToReturn else {
            throw DomainError.userNotFound
        }
        
        return user
    }
}

// MARK: - Mock Data Extensions
extension User {
    static var mockUser1: User {
        User(
            id: 1,
            name: "John Doe",
            username: "johndoe",
            email: "john@example.com",
            phone: "+1-234-567-8900",
            website: "johndoe.com",
            company: Company.mockCompany1,
            address: Address.mockAddress1
        )
    }
    
    static var mockUser2: User {
        User(
            id: 2,
            name: "Jane Smith",
            username: "janesmith",
            email: "jane@example.com",
            phone: "+1-555-123-4567",
            website: "janesmith.org",
            company: Company.mockCompany2,
            address: Address.mockAddress2
        )
    }
}

extension Company {
    static var mockCompany1: Company {
        Company(
            name: "Tech Corp",
            catchPhrase: "Innovative solutions",
            bs: "synergistic actionable"
        )
    }
    
    static var mockCompany2: Company {
        Company(
            name: "Design Studio",
            catchPhrase: "Creative excellence",
            bs: "intuitive user-centric"
        )
    }
}

extension Address {
    static var mockAddress1: Address {
        Address(
            street: "123 Main St",
            suite: "Apt 456",
            city: "New York",
            zipcode: "10001",
            geo: Geo(lat: "40.7128", lng: "-74.0060")
        )
    }
    
    static var mockAddress2: Address {
        Address(
            street: "456 Oak Ave",
            suite: "Suite 789",
            city: "Los Angeles",
            zipcode: "90210",
            geo: Geo(lat: "34.0522", lng: "-118.2437")
        )
    }
}

extension UserDTO {
    static var mockUser1: UserDTO {
        UserDTO(
            id: 1,
            name: "John Doe",
            username: "johndoe",
            email: "john@example.com",
            phone: "+1-234-567-8900",
            website: "johndoe.com",
            company: CompanyDTO.mockCompany1,
            address: AddressDTO.mockAddress1
        )
    }
    
    static var mockUser2: UserDTO {
        UserDTO(
            id: 2,
            name: "Jane Smith",
            username: "janesmith",
            email: "jane@example.com",
            phone: "+1-555-123-4567",
            website: "janesmith.org",
            company: CompanyDTO.mockCompany2,
            address: AddressDTO.mockAddress2
        )
    }
}

extension CompanyDTO {
    static var mockCompany1: CompanyDTO {
        CompanyDTO(
            name: "Tech Corp",
            catchPhrase: "Innovative solutions",
            bs: "synergistic actionable"
        )
    }
    
    static var mockCompany2: CompanyDTO {
        CompanyDTO(
            name: "Design Studio",
            catchPhrase: "Creative excellence",
            bs: "intuitive user-centric"
        )
    }
}

extension AddressDTO {
    static var mockAddress1: AddressDTO {
        AddressDTO(
            street: "123 Main St",
            suite: "Apt 456",
            city: "New York",
            zipcode: "10001",
            geo: GeoDTO(lat: "40.7128", lng: "-74.0060")
        )
    }
    
    static var mockAddress2: AddressDTO {
        AddressDTO(
            street: "456 Oak Ave",
            suite: "Suite 789",
            city: "Los Angeles",
            zipcode: "90210",
            geo: GeoDTO(lat: "34.0522", lng: "-118.2437")
        )
    }
}

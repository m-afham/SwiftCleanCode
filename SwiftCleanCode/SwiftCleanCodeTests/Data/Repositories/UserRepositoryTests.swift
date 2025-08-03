//
//  UserRepositoryTests.swift
//  SwiftCleanCodeTests
//
//  Created by Afham on 04/08/2025.
//

import XCTest
@testable import SwiftCleanCode

final class UserRepositoryTests: XCTestCase {
    
    private var sut: UserRepository!
    private var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = UserRepository(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testFetchUsers_WhenNetworkServiceReturnsUsers_ShouldReturnDomainUsers() async throws {
        // Given
        let userDTOs = [UserDTO.mockUser1, UserDTO.mockUser2]
        mockNetworkService.dataToReturn = userDTOs
        
        // When
        let users = try await sut.fetchUsers()
        
        // Then
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].id, userDTOs[0].id)
        XCTAssertEqual(users[0].name, userDTOs[0].name)
        XCTAssertEqual(users[1].id, userDTOs[1].id)
        XCTAssertEqual(users[1].name, userDTOs[1].name)
        XCTAssertTrue(mockNetworkService.requestCalled)
    }
    
    func testFetchUsers_WhenNetworkServiceThrowsNetworkError_ShouldThrowDomainError() async {
        // Given
        mockNetworkService.errorToThrow = NetworkError.serverError(500)
        
        // When & Then
        do {
            _ = try await sut.fetchUsers()
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            if case .networkError(let message) = error {
                XCTAssertTrue(message.contains("Server error"))
            } else {
                XCTFail("Expected network error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchUsers_WhenNetworkServiceThrowsDecodingError_ShouldThrowDomainDecodingError() async {
        // Given
        mockNetworkService.errorToThrow = NetworkError.decodingError("Invalid JSON")
        
        // When & Then
        do {
            _ = try await sut.fetchUsers()
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            if case .decodingError(let message) = error {
                XCTAssertEqual(message, "Invalid JSON")
            } else {
                XCTFail("Expected decoding error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchUser_WhenNetworkServiceReturnsUser_ShouldReturnDomainUser() async throws {
        // Given
        let userDTO = UserDTO.mockUser1
        let userId = 1
        mockNetworkService.dataToReturn = userDTO
        
        // When
        let user = try await sut.fetchUser(by: userId)
        
        // Then
        XCTAssertEqual(user.id, userDTO.id)
        XCTAssertEqual(user.name, userDTO.name)
        XCTAssertEqual(user.email, userDTO.email)
        XCTAssertTrue(mockNetworkService.requestCalled)
    }
    
    func testFetchUser_WhenNetworkServiceThrows404_ShouldThrowUserNotFound() async {
        // Given
        mockNetworkService.errorToThrow = NetworkError.serverError(404)
        
        // When & Then
        do {
            _ = try await sut.fetchUser(by: 999)
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            XCTAssertEqual(error, DomainError.userNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchUser_WhenNetworkServiceThrowsInvalidURL_ShouldThrowNetworkError() async {
        // Given
        mockNetworkService.errorToThrow = NetworkError.invalidURL
        
        // When & Then
        do {
            _ = try await sut.fetchUser(by: 1)
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            if case .networkError(let message) = error {
                XCTAssertEqual(message, "Invalid network request")
            } else {
                XCTFail("Expected network error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

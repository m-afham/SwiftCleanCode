//
//  FetchUsersUseCaseTests.swift
//  SwiftCleanCodeTests
//
//  Created by Afham on 04/08/2025.
//

import XCTest
@testable import SwiftCleanCode

final class FetchUsersUseCaseTests: XCTestCase {
    
    private var sut: FetchUsersUseCase!
    private var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = FetchUsersUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecute_WhenRepositoryReturnsUsers_ShouldReturnUsers() async throws {
        // Given
        let expectedUsers = [User.mockUser1, User.mockUser2]
        mockRepository.usersToReturn = expectedUsers
        
        // When
        let users = try await sut.execute()
        
        // Then
        XCTAssertEqual(users, expectedUsers)
        XCTAssertTrue(mockRepository.fetchUsersCalled)
    }
    
    func testExecute_WhenRepositoryThrowsNetworkError_ShouldThrowSameError() async {
        // Given
        let expectedError = DomainError.networkError("Network unavailable")
        mockRepository.errorToThrow = expectedError
        
        // When & Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testExecute_WhenRepositoryThrowsDecodingError_ShouldThrowSameError() async {
        // Given
        let expectedError = DomainError.decodingError("Invalid JSON")
        mockRepository.errorToThrow = expectedError
        
        // When & Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

final class FetchUserUseCaseTests: XCTestCase {
    
    private var sut: FetchUserUseCase!
    private var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = FetchUserUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecute_WhenRepositoryReturnsUser_ShouldReturnUser() async throws {
        // Given
        let expectedUser = User.mockUser1
        let userId = 1
        mockRepository.userToReturn = expectedUser
        
        // When
        let user = try await sut.execute(userId: userId)
        
        // Then
        XCTAssertEqual(user, expectedUser)
        XCTAssertTrue(mockRepository.fetchUserCalled)
        XCTAssertEqual(mockRepository.fetchUserIdParameter, userId)
    }
    
    func testExecute_WhenRepositoryThrowsUserNotFound_ShouldThrowSameError() async {
        // Given
        let expectedError = DomainError.userNotFound
        mockRepository.errorToThrow = expectedError
        
        // When & Then
        do {
            _ = try await sut.execute(userId: 999)
            XCTFail("Expected to throw error")
        } catch let error as DomainError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

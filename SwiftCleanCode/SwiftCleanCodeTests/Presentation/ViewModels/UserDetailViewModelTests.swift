//
//  UserDetailViewModelTests.swift
//  SwiftCleanCodeTests
//
//  Created by Afham on 04/08/2025.
//

import XCTest
import Combine
@testable import SwiftCleanCode

@MainActor
final class UserDetailViewModelTests: XCTestCase {
    
    private var sut: UserDetailViewModel!
    private var mockFetchUserUseCase: MockFetchUserUseCase!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFetchUserUseCase = MockFetchUserUseCase()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockFetchUserUseCase = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitWithUserId_ShouldSetCorrectInitialState() {
        // Given
        let userId = 1
        
        // When
        sut = UserDetailViewModel(userId: userId, fetchUserUseCase: mockFetchUserUseCase)
        
        // Then
        XCTAssertNil(sut.user)
        if case .idle = sut.loadingState {
            // Success
        } else {
            XCTFail("Expected idle state")
        }
    }
    
    func testInitWithUser_ShouldSetUserAndLoadedState() {
        // Given
        let user = User.mockUser1
        
        // When
        sut = UserDetailViewModel(user: user, fetchUserUseCase: mockFetchUserUseCase)
        
        // Then
        XCTAssertEqual(sut.user, user)
        if case .loaded = sut.loadingState {
            // Success
        } else {
            XCTFail("Expected loaded state")
        }
    }
    
    func testFetchUser_WhenUseCaseReturnsUser_ShouldUpdateUserAndState() async {
        // Given
        let userId = 1
        let expectedUser = User.mockUser1
        mockFetchUserUseCase.userToReturn = expectedUser
        sut = UserDetailViewModel(userId: userId, fetchUserUseCase: mockFetchUserUseCase)
        
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [LoadingState] = []
        
        sut.$loadingState
            .sink { state in
                loadingStates.append(state)
                if loadingStates.count == 3 { // idle -> loading -> loaded
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchUser()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(sut.user, expectedUser)
        XCTAssertTrue(mockFetchUserUseCase.executeCalled)
        XCTAssertEqual(mockFetchUserUseCase.userIdParameter, userId)
        
        if case .loaded = sut.loadingState {
            // Success
        } else {
            XCTFail("Expected loaded state")
        }
    }
    
    func testFetchUser_WhenUseCaseThrowsError_ShouldUpdateStateToError() async {
        // Given
        let userId = 999
        let expectedError = DomainError.userNotFound
        mockFetchUserUseCase.errorToThrow = expectedError
        sut = UserDetailViewModel(userId: userId, fetchUserUseCase: mockFetchUserUseCase)
        
        let expectation = XCTestExpectation(description: "Error state reached")
        
        sut.$loadingState
            .sink { state in
                if case .error = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchUser()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        
        if case .error(let message) = sut.loadingState {
            XCTAssertEqual(message, expectedError.localizedDescription)
        } else {
            XCTFail("Expected error state")
        }
        
        XCTAssertNil(sut.user)
    }
    
    func testRefreshUser_WithExistingUser_ShouldCallFetchUserUseCase() async {
        // Given
        let user = User.mockUser1
        let updatedUser = User.mockUser2
        mockFetchUserUseCase.userToReturn = updatedUser
        sut = UserDetailViewModel(user: user, fetchUserUseCase: mockFetchUserUseCase)
        
        // When
        sut.refreshUser()
        
        // Give some time for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertTrue(mockFetchUserUseCase.executeCalled)
        XCTAssertEqual(mockFetchUserUseCase.userIdParameter, user.id)
    }
    
    func testRefreshUser_WhenUseCaseReturnsUpdatedUser_ShouldUpdateUser() async {
        // Given
        let originalUser = User.mockUser1
        let updatedUser = User(
            id: originalUser.id,
            name: "Updated Name",
            username: originalUser.username,
            email: "updated@example.com",
            phone: originalUser.phone,
            website: originalUser.website,
            company: originalUser.company,
            address: originalUser.address
        )
        
        mockFetchUserUseCase.userToReturn = updatedUser
        sut = UserDetailViewModel(user: originalUser, fetchUserUseCase: mockFetchUserUseCase)
        
        let expectation = XCTestExpectation(description: "User updated")
        
        sut.$user
            .dropFirst() // Skip initial value
            .sink { user in
                if user?.name == "Updated Name" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.refreshUser()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(sut.user?.name, "Updated Name")
        XCTAssertEqual(sut.user?.email, "updated@example.com")
    }
}

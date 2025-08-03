//
//  UserListViewModelTests.swift
//  SwiftCleanCodeTests
//
//  Created by Afham on 04/08/2025.
//

import XCTest
import Combine
@testable import SwiftCleanCode

@MainActor
final class UserListViewModelTests: XCTestCase {
    
    private var sut: UserListViewModel!
    private var mockFetchUsersUseCase: MockFetchUsersUseCase!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFetchUsersUseCase = MockFetchUsersUseCase()
        sut = UserListViewModel(fetchUsersUseCase: mockFetchUsersUseCase)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockFetchUsersUseCase = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertTrue(sut.users.isEmpty)
        XCTAssertEqual(sut.searchText, "")
        if case .idle = sut.loadingState {
            // Success
        } else {
            XCTFail("Expected idle state")
        }
    }
    
    func testFetchUsers_WhenUseCaseReturnsUsers_ShouldUpdateUsersAndState() async {
        // Given
        let expectedUsers = [User.mockUser1, User.mockUser2]
        mockFetchUsersUseCase.usersToReturn = expectedUsers
        
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
        sut.fetchUsers()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(sut.users, expectedUsers)
        XCTAssertTrue(mockFetchUsersUseCase.executeCalled)
        
        if case .loaded = sut.loadingState {
            // Success
        } else {
            XCTFail("Expected loaded state, got: \(sut.loadingState)")
        }
    }
    
    func testFetchUsers_WhenUseCaseThrowsError_ShouldUpdateStateToError() async {
        // Given
        let expectedError = DomainError.networkError("Network unavailable")
        mockFetchUsersUseCase.errorToThrow = expectedError
        
        let expectation = XCTestExpectation(description: "Error state reached")
        
        sut.$loadingState
            .sink { state in
                if case .error = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchUsers()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        
        if case .error(let message) = sut.loadingState {
            XCTAssertEqual(message, expectedError.localizedDescription)
        } else {
            XCTFail("Expected error state")
        }
        
        XCTAssertTrue(sut.users.isEmpty)
    }
    
    func testFilteredUsers_WhenSearchTextIsEmpty_ShouldReturnAllUsers() {
        // Given
        sut.users = [User.mockUser1, User.mockUser2]
        sut.searchText = ""
        
        // When
        let filteredUsers = sut.filteredUsers
        
        // Then
        XCTAssertEqual(filteredUsers.count, 2)
        XCTAssertEqual(filteredUsers, sut.users)
    }
    
    func testFilteredUsers_WhenSearchTextMatchesName_ShouldReturnMatchingUsers() {
        // Given
        sut.users = [User.mockUser1, User.mockUser2]
        sut.searchText = "John"
        
        // When
        let filteredUsers = sut.filteredUsers
        
        // Then
        XCTAssertEqual(filteredUsers.count, 1)
        XCTAssertEqual(filteredUsers.first?.name, "John Doe")
    }
    
    func testFilteredUsers_WhenSearchTextMatchesEmail_ShouldReturnMatchingUsers() {
        // Given
        sut.users = [User.mockUser1, User.mockUser2]
        sut.searchText = "jane@"
        
        // When
        let filteredUsers = sut.filteredUsers
        
        // Then
        XCTAssertEqual(filteredUsers.count, 1)
        XCTAssertEqual(filteredUsers.first?.email, "jane@example.com")
    }
    
    func testFilteredUsers_WhenSearchTextDoesNotMatch_ShouldReturnEmptyArray() {
        // Given
        sut.users = [User.mockUser1, User.mockUser2]
        sut.searchText = "NonExistent"
        
        // When
        let filteredUsers = sut.filteredUsers
        
        // Then
        XCTAssertTrue(filteredUsers.isEmpty)
    }
    
    func testRefreshUsers_ShouldCallFetchUsersUseCase() async {
        // Given
        let expectedUsers = [User.mockUser1]
        mockFetchUsersUseCase.usersToReturn = expectedUsers
        
        // When
        sut.refreshUsers()
        
        // Give some time for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertTrue(mockFetchUsersUseCase.executeCalled)
    }
}

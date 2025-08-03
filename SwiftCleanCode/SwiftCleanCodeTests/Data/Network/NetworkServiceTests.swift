//
//  NetworkServiceTests.swift
//  SwiftCleanCodeTests
//
//  Created by Afham on 04/08/2025.
//

import XCTest
@testable import SwiftCleanCode

final class NetworkServiceTests: XCTestCase {
    
    private var sut: NetworkService!
    private var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = NetworkService(session: mockSession)
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testRequest_WhenValidResponse_ShouldReturnDecodedData() async throws {
        // Given
        let expectedUser = UserDTO.mockUser1
        let jsonData = try JSONEncoder().encode(expectedUser)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockSession.dataToReturn = (jsonData, httpResponse)
        
        // When
        let result = try await sut.request(UserEndpoint.fetchUser(id: 1), responseType: UserDTO.self)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.name, expectedUser.name)
        XCTAssertEqual(result.email, expectedUser.email)
    }
    
    func testRequest_WhenServerError_ShouldThrowServerError() async {
        // Given
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockSession.dataToReturn = (Data(), httpResponse)
        
        // When & Then
        do {
            _ = try await sut.request(UserEndpoint.fetchUsers, responseType: [UserDTO].self)
            XCTFail("Expected to throw server error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected server error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRequest_WhenInvalidResponse_ShouldThrowInvalidResponseError() async {
        // Given
        let invalidResponse = URLResponse()
        mockSession.dataToReturn = (Data(), invalidResponse)
        
        // When & Then
        do {
            _ = try await sut.request(UserEndpoint.fetchUsers, responseType: [UserDTO].self)
            XCTFail("Expected to throw invalid response error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRequest_WhenInvalidJSON_ShouldThrowDecodingError() async {
        // Given
        let invalidJsonData = "invalid json".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockSession.dataToReturn = (invalidJsonData, httpResponse)
        
        // When & Then
        do {
            _ = try await sut.request(UserEndpoint.fetchUsers, responseType: [UserDTO].self)
            XCTFail("Expected to throw decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success - this is what we expect
            } else {
                XCTFail("Expected decoding error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

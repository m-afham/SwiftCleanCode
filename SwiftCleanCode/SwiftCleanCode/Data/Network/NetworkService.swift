//
//  NetworkService.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - URL Session Protocol
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession Extension
extension URLSession: URLSessionProtocol {}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let request = try endpoint.asURLRequest()
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            let decodedData = try decoder.decode(responseType, from: data)
            return decodedData
            
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError.localizedDescription)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(String)
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .serverError(let code):
            return "Server Error: \(code)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}

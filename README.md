# Swift Clean Architecture: API Integration & UI Updates

A comprehensive guide to implementing Clean Architecture in Swift for live coding interviews, featuring real API integration and comprehensive testing.

## Architecture Overview

This project demonstrates Clean Architecture principles with clear separation of concerns across four distinct layers:

```
┌─────────────────────────────────────────┐
│              Presentation               │
│          (Views, ViewModels)            │
├─────────────────────────────────────────┤
│               Domain                    │
│         (Entities, Use Cases)           │
├─────────────────────────────────────────┤
│                Data                     │
│      (Network, Repositories, DTOs)      │
├─────────────────────────────────────────┤
│          Dependency Injection           │
│             (DI Container)              │
└─────────────────────────────────────────┘
```

## Project Structure

```
SwiftCleanCode/
├── Domain/
│   ├── Entities/
│   │   └── User.swift
│   ├── Repositories/
│   │   └── UserRepositoryProtocol.swift
│   └── UseCases/
│       └── FetchUsersUseCase.swift
├── Data/
│   ├── Network/
│   │   ├── NetworkService.swift
│   │   └── APIEndpoint.swift
│   ├── Models/
│   │   └── UserDTO.swift
│   └── Repositories/
│       └── UserRepository.swift
├── Presentation/
│   ├── ViewModels/
│   │   ├── UserListViewModel.swift
│   │   └── UserDetailViewModel.swift
│   └── Views/
│       ├── UserListView.swift
│       └── UserDetailView.swift
├── DI/
│   └── DIContainer.swift
└── Tests/
    ├── Domain/
    ├── Data/
    └── Presentation/
```

## Component Communication Flow

Here's a visual representation of how components communicate in our clean architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERACTION                         │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                             │
│  ┌─────────────┐     ┌─────────────────────────────────────┐    │
│  │    View     │────▶│         ViewModel                   │    │
│  │ (SwiftUI)   │◀────│    (@Published properties)          │    │
│  └─────────────┘     └──────────────┬──────────────────────┘    │
└─────────────────────────────────────┼───────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                                 │
│              ┌─────────────────────────────────────┐            │
│              │             Use Case                │            │
│              │        (Business Logic)             │            │
│              └──────────────┬──────────────────────┘            │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DATA LAYER                                  │
│  ┌─────────────────┐        ┌──────────────────────────────┐    │
│  │   Repository    │───────▶│       NetworkService         │    │
│  │(DTO→Domain Map) │◀───────│     (API Communication)      │    │
│  └─────────────────┘        └──────────────┬───────────────┘    │
└────────────────────────────────────────────┼────────────────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │   External API  │
                                    │(JSONPlaceholder)|
                                    └─────────────────┘
```

## Layer Breakdown

### 1. Domain Layer

The core business logic layer that's independent of any external frameworks.

#### Entities
Pure Swift models representing business objects:

```swift
struct User: Identifiable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let company: Company
    let address: Address
}

struct Company: Equatable {
    let name: String
    let catchPhrase: String
    let bs: String
}
```

#### Repository Protocols
Define contracts for data operations:

```swift
protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [User]
    func fetchUser(by id: Int) async throws -> User
}

enum DomainError: Error, Equatable {
    case networkError(String)
    case decodingError(String)
    case userNotFound
    case unknown(String)
}
```

#### Use Cases
Encapsulate specific business rules:

```swift
final class FetchUsersUseCase: FetchUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [User] {
        return try await repository.fetchUsers()
    }
}
```

### 2. Data Layer

Handles external data sources and implements repository protocols.

#### Network Service
Protocol-based networking with proper error handling:

```swift
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSessionProtocol
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let request = try endpoint.asURLRequest()
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(responseType, from: data)
    }
}
```

#### API Endpoints
Type-safe endpoint configuration:

```swift
enum UserEndpoint: APIEndpoint {
    case fetchUsers
    case fetchUser(id: Int)
    
    var baseURL: String { "https://jsonplaceholder.typicode.com" }
    
    var path: String {
        switch self {
        case .fetchUsers: return "/users"
        case .fetchUser(let id): return "/users/\(id)"
        }
    }
}
```

#### DTOs (Data Transfer Objects)
Map API responses to domain models:

```swift
struct UserDTO: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    // ... other properties
}

extension UserDTO {
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            username: username,
            email: email,
            // ... map other properties
        )
    }
}
```

#### Repository Implementation
Concrete implementation of repository protocols:

```swift
final class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    func fetchUsers() async throws -> [User] {
        let userDTOs = try await networkService.request(
            UserEndpoint.fetchUsers,
            responseType: [UserDTO].self
        )
        return userDTOs.map { $0.toDomain() }
    }
}
```

### 3. Presentation Layer

Manages UI state and user interactions using MVVM pattern.

#### ViewModels
Handle UI logic and state management:

```swift
@MainActor
final class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var loadingState: LoadingState = .idle
    @Published var searchText: String = ""
    
    private let fetchUsersUseCase: FetchUsersUseCaseProtocol
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.username.localizedCaseInsensitiveContains(searchText) ||
            user.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchUsers() {
        Task {
            loadingState = .loading
            do {
                users = try await fetchUsersUseCase.execute()
                loadingState = .loaded
            } catch {
                loadingState = .error(error.localizedDescription)
            }
        }
    }
}
```

#### Views
SwiftUI views that observe ViewModels:

```swift
struct UserListView: View {
    @StateObject private var viewModel: UserListViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                switch viewModel.loadingState {
                case .loading:
                    LoadingView()
                case .loaded:
                    UserList(users: viewModel.filteredUsers)
                case .error(let message):
                    ErrorView(message: message) {
                        viewModel.fetchUsers()
                    }
                }
            }
            .navigationTitle("Users")
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}
```

### 4. Dependency Injection

Manages dependencies and provides proper abstraction:

```swift
final class DIContainer {
    static let shared = DIContainer()
    
    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(networkService: networkService)
    }()
    
    func makeFetchUsersUseCase() -> FetchUsersUseCaseProtocol {
        return FetchUsersUseCase(repository: userRepository)
    }
    
    @MainActor
    func makeUserListViewModel() -> UserListViewModel {
        return UserListViewModel(fetchUsersUseCase: makeFetchUsersUseCase())
    }
}
```

## Testing Strategy

### Unit Testing Each Layer

#### Domain Layer Tests
```swift
final class FetchUsersUseCaseTests: XCTestCase {
    func testExecute_WhenRepositoryReturnsUsers_ShouldReturnUsers() async throws {
        // Given
        let mockRepository = MockUserRepository()
        mockRepository.usersToReturn = [User.mockUser1, User.mockUser2]
        let sut = FetchUsersUseCase(repository: mockRepository)
        
        // When
        let users = try await sut.execute()
        
        // Then
        XCTAssertEqual(users.count, 2)
        XCTAssertTrue(mockRepository.fetchUsersCalled)
    }
}
```

#### Data Layer Tests
```swift
final class NetworkServiceTests: XCTestCase {
    func testRequest_WhenValidResponse_ShouldReturnDecodedData() async throws {
        // Given
        let mockSession = MockURLSession()
        let expectedUser = UserDTO.mockUser1
        let jsonData = try JSONEncoder().encode(expectedUser)
        mockSession.dataToReturn = (jsonData, HTTPURLResponse(/* valid response */))
        
        let sut = NetworkService(session: mockSession)
        
        // When
        let result = try await sut.request(UserEndpoint.fetchUser(id: 1), responseType: UserDTO.self)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
    }
}
```

#### Presentation Layer Tests
```swift
@MainActor
final class UserListViewModelTests: XCTestCase {
    func testFetchUsers_WhenUseCaseReturnsUsers_ShouldUpdateUsersAndState() async {
        // Given
        let mockUseCase = MockFetchUsersUseCase()
        mockUseCase.usersToReturn = [User.mockUser1, User.mockUser2]
        let sut = UserListViewModel(fetchUsersUseCase: mockUseCase)
        
        // When
        sut.fetchUsers()
        
        // Give time for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertTrue(mockUseCase.executeCalled)
    }
}
```

### Communication Flow Steps:

1. **User Interaction** → View receives user input (tap, search, etc.)
2. **View** → ViewModel via method calls (`fetchUsers()`, `searchText` binding)
3. **ViewModel** → Use Case via protocol methods (`execute()`)
4. **Use Case** → Repository via protocol methods (`fetchUsers()`)
5. **Repository** → NetworkService via request methods
6. **NetworkService** → External API via HTTP requests
7. **Response Flow**: API → NetworkService → Repository → Use Case → ViewModel → View
8. **UI Update**: ViewModel publishes changes, View automatically updates

### Key Communication Principles:

- **Unidirectional Data Flow**: Data flows down, events flow up
- **Protocol-Based**: Each layer communicates through abstractions
- **Dependency Injection**: DI Container assembles and provides dependencies
- **Async/Await**: Modern Swift concurrency for network operations
- **Error Propagation**: Errors are mapped and handled at each layer

## 🎤 Mock Interview Conversation

### **Interviewer**: "We need you to create an app that fetches users from an API and displays them in a list. How would you approach this?"

**You**: "I'd structure this using Clean Architecture to ensure maintainability and testability. Let me break down my approach:

First, I'd create the domain layer with a `User` entity and a `UserRepositoryProtocol` to define the contract for data operations. This keeps the business logic independent of external dependencies."

### **Interviewer**: "Good start. How would you handle the API integration?"

**You**: "I'd implement the data layer with three key components:

1. **NetworkService**: A protocol-based service that handles HTTP requests
2. **APIEndpoint**: Type-safe endpoint definitions using enums
3. **UserRepository**: Concrete implementation that uses the NetworkService and maps DTOs to domain models

This separation allows me to easily mock the network layer for testing."

### **Interviewer**: "What about the UI? How would you handle loading states and errors?"

**You**: "I'd use MVVM in the presentation layer:

1. **UserListViewModel**: Manages UI state with `@Published` properties for users, loading state, and search functionality
2. **UserListView**: SwiftUI view that observes the ViewModel and reacts to state changes

For loading states, I'd use an enum with cases like `.idle`, `.loading`, `.loaded`, and `.error(String)` to provide clear UI feedback."

### **Interviewer**: "How would you handle dependency injection?"

**You**: "I'd create a `DIContainer` that manages the creation and injection of dependencies. This follows the dependency inversion principle where high-level modules don't depend on low-level modules, but both depend on abstractions."

### **Interviewer**: "What about testing?"

**You**: "Each layer would have comprehensive unit tests using mocks:
- Domain layer tests verify business logic
- Data layer tests ensure proper API integration and error handling
- Presentation layer tests validate UI state management

I'd use protocols throughout to enable easy mocking and maintain high test coverage."

## 🚀 Getting Started

1. Clone the repository
2. Open `SwiftCleanCode.xcodeproj` in Xcode
3. Build and run the project
4. Run tests with `Cmd + U`

## 🔗 Key Benefits

- **Testability**: Each layer can be tested independently
- **Maintainability**: Clear separation of concerns makes code easier to modify
- **Scalability**: Easy to add new features without affecting existing code
- **Platform Independence**: Domain layer is pure Swift and can be reused across platforms

## 📚 Additional Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [iOS Clean Architecture Guide](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)
- [Swift Testing Best Practices](https://developer.apple.com/documentation/xctest)

## ❓ Frequently Asked Questions

### **Q: What is the Domain layer?**
**A:** The Domain layer contains the core business logic, entities, and use cases. It's the innermost layer that doesn't depend on any external frameworks or libraries. It defines what the application does, not how it does it.

### **Q: What is the Data layer?**
**A:** The Data layer handles all external data sources like APIs, databases, and local storage. It implements the repository protocols defined in the Domain layer and is responsible for data retrieval, caching, and persistence.

### **Q: What is a DTO (Data Transfer Object)?**
**A:** DTOs are simple objects that carry data between different layers or systems. They typically mirror the structure of API responses and are used to decouple the external API format from your internal domain models.

### **Q: Where should I put models for APIs?**
**A:** API models (DTOs) belong in the Data layer under a `Models` or `DTOs` folder. These models should have mapping functions to convert to domain entities.

### **Q: What's the difference between DTO and Domain models?**
**A:** 
- **DTOs**: Reflect the API structure, include all API fields, used for serialization/deserialization
- **Domain Models**: Reflect business requirements, may combine multiple DTOs, contain business logic

### **Q: Where should I keep protocols?**
**A:** Repository and use case protocols belong in the Domain layer. Network protocols belong in the Data layer. This ensures the Domain layer defines contracts without knowing about implementation details.

### **Q: What can a Repository have and what not?**
**A:** 
**✅ Repository Can Have:**
- API calls and network requests
- Data caching logic
- Data persistence operations
- Error mapping from network to domain errors
- Data transformation (DTO to Domain mapping)

**❌ Repository Should NOT Have:**
- Business logic or rules
- UI-related code
- Direct access to ViewModels
- Complex data processing that belongs in Use Cases

### **Q: How do I handle errors across layers?**
**A:** Define domain-specific errors in the Domain layer and map external errors (network, parsing) to domain errors in the Data layer. This keeps error handling consistent throughout the app.

### **Q: Should ViewModels call Repositories directly?**
**A:** No, ViewModels should call Use Cases, which then interact with Repositories. This maintains proper separation of concerns and makes testing easier.

### **Q: How do I test network calls?**
**A:** Use protocol-based dependency injection. Create a `URLSessionProtocol` that `URLSession` conforms to, then create mock implementations for testing. This allows you to test network logic without making actual HTTP requests.

### **Q: Where should I put validation logic?**
**A:** Business validation belongs in the Domain layer (entities or use cases). UI validation (format checking) can be in ViewModels. Data validation (API response validation) belongs in the Data layer.

### **Q: What's the best way to handle loading states?**
**A:** Use an enum to represent different states: `.idle`, `.loading`, `.loaded`, `.error(String)`. This provides type safety and makes it easy to handle all possible states in the UI.

### **Q: How should I structure my test files?**
**A:** Mirror your main project structure in tests. Create separate test classes for each component and use the naming convention `ComponentNameTests`. Group tests by functionality and use descriptive test method names.

### **Q: What's the role of Use Cases in small apps?**
**A:** Even in small apps, Use Cases provide clear entry points for business operations, make testing easier, and prepare your app for future growth. They're especially valuable during interviews as they demonstrate understanding of separation of concerns.

---

## 👨‍💻 About the Author

**Created by M. Afham** - iOS/macOS Apps Developer

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/m-afham/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/m-afham/)
[![Stack Overflow](https://img.shields.io/badge/Stack%20Overflow-F58025?style=for-the-badge&logo=stackoverflow&logoColor=white)](https://stackoverflow.com/users/8451247/m-afham?tab=profile)

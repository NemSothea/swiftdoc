# SwiftUI Workshop Slides & Code & Integration & Polish & App Showcase & Next Steps

## Hour 1: Managing Complex State

### Slide 1: State Management Overview
```
┌─────────────────────────────────┐
│   SwiftUI State Management      │
├─────────────────────────────────┤
│                                 │
│   @State        → Local view    │
│   @StateObject  → Complex data  │
│   @ObservedObject → Passed data │
│   @EnvironmentObject → Global   │
│                                 │
└─────────────────────────────────┘
```

### Slide 2: ObservableObject Protocol
```swift
// The data manager (like ViewController's role)
class UserDataManager: ObservableObject {
    @Published var username: String = "Guest"
    @Published var score: Int = 0
    @Published var isLoggedIn: Bool = false
    
    func login() {
        username = "JohnDoe"
        score = 100
        isLoggedIn = true
    }
}
```

### Slide 3: @StateObject in SwiftUI View
```swift
struct ContentView: View {
    // Creates and owns the instance
    @StateObject private var userData = UserDataManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(userData.username)")
                .font(.title)
            
            Text("Score: \(userData.score)")
                .font(.headline)
            
            Button("Login") {
                userData.login()
            }
            .padding()
            .background(userData.isLoggedIn ? Color.green : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
```

### Slide 4: @ObservedObject for Sharing
```swift
// Parent View
struct ParentView: View {
    @StateObject private var dataManager = UserDataManager()
    
    var body: some View {
        VStack {
            ChildView(userData: dataManager)
            // Other views that use dataManager
        }
    }
}

// Child View
struct ChildView: View {
    @ObservedObject var userData: UserDataManager
    
    var body: some View {
        Button("Add Points") {
            userData.score += 10
        }
    }
}
```

### Slide 5: Complete Example - Task Manager
```swift
// Model
struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

// ObservableObject Manager
class TaskManager: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var filter = "All"
    
    var filteredTasks: [TaskItem] {
        switch filter {
        case "Completed":
            return tasks.filter { $0.isCompleted }
        case "Pending":
            return tasks.filter { !$0.isCompleted }
        default:
            return tasks
        }
    }
    
    func addTask(_ title: String) {
        let newTask = TaskItem(title: title, isCompleted: false)
        tasks.append(newTask)
    }
    
    func toggleTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}

// Main View
struct TaskListView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Add Task Section
                HStack {
                    TextField("New task...", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        guard !newTaskTitle.isEmpty else { return }
                        taskManager.addTask(newTaskTitle)
                        newTaskTitle = ""
                    }
                }
                .padding()
                
                // Filter Picker
                Picker("Filter", selection: $taskManager.filter) {
                    Text("All").tag("All")
                    Text("Pending").tag("Pending")
                    Text("Completed").tag("Completed")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Task List
                List {
                    ForEach(taskManager.filteredTasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? 
                                  "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                            
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            taskManager.toggleTask(task)
                        }
                    }
                }
            }
            .navigationTitle("Tasks (\(taskManager.filteredTasks.count))")
        }
    }
}
```

---

## Hour 2: Networking with URLSession

### Slide 6: Basic Async/Await Network Call
```swift
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

class NetworkManager {
    func fetchUsers() async throws -> [User] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        
        // Basic async/await call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let users = try JSONDecoder().decode([User].self, from: data)
        return users
    }
}
```

### Slide 7: Network Manager with ObservableObject
```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager()
    
    @MainActor
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            users = try await networkManager.fetchUsers()
        } catch {
            errorMessage = error.localizedDescription
            print("Error: \(error)")
        }
        
        isLoading = false
    }
}
```

### Slide 8: SwiftUI View with Async Network Call
```swift
struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                        .scaleEffect(1.5)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadUsers()
                        }
                    }
                } else {
                    List(viewModel.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .toolbar {
                Button("Refresh") {
                    Task {
                        await viewModel.loadUsers()
                    }
                }
            }
            .task {
                // Auto-load when view appears
                await viewModel.loadUsers()
            }
        }
    }
}

// Error View Component
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error: \(message)")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### Slide 9: Advanced Network Layer
```swift
// Generic Network Service
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
}

class APIService {

    static let shared = APIService()
    private let session = URLSession.shared
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: String = "GET"
    ) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

// Example Usage
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    
    @MainActor
    func fetchPosts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            posts = try await APIService.shared.request(
                "https://jsonplaceholder.typicode.com/posts"
            )
        } catch {
            print("Failed to fetch posts: \(error)")
        }
    }
}
```

### Slide 10: POST Request Example
```swift
extension APIService {
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw NetworkError.invalidURL
        }
        
        let newPost = CreatePost(title: title, body: body, userId: userId)
        let jsonData = try JSONEncoder().encode(newPost)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Post.self, from: data)
    }
}

struct CreatePost: Codable {
    let title: String
    let body: String
    let userId: Int
}
```

---



### Tips for Project Work:
1. **Start Simple**: Build core functionality first
2. **Test API Calls**: Use mock data or JSONPlaceholder
3. **Handle Errors**: Always include error states
4. **Use Task**: For async calls in SwiftUI
5. **@MainActor**: Update UI on main thread
6. **Preview Provider**: Test with mock data

### Exercise Tasks:
1. Create a Task Manager with Cloud sync
2. Build a News Reader app with categories
3. Make a Crypto Tracker with real API data
4. Create a Recipe app with search functionality

### Resources:
- [JSONPlaceholder](https://jsonplaceholder.typicode.com/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
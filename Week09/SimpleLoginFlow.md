# Ultra Simple Login Flow

```swift
import SwiftUI

// MARK: - 1. Auth Manager (Only 9 lines)
class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username = ""
    
    func login(user: String, pass: String) {
        // Simple validation
        if !user.isEmpty && !pass.isEmpty {
            isLoggedIn = true
            username = user
        }
    }
    
    func logout() {
        isLoggedIn = false
        username = ""
    }
}

// MARK: - 2. Main App (3 lines)
@main
struct SimpleApp: App {
    @StateObject var auth = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
        .environmentObject(auth)
    }
}

// MARK: - 3. Login Screen (15 lines)
struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var user = ""
    @State private var pass = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.largeTitle)
            
            TextField("Username", text: $user)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            SecureField("Password", text: $pass)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Login") {
                auth.login(user: user, pass: pass)
            }
            .buttonStyle(.borderedProminent)
            .disabled(user.isEmpty || pass.isEmpty)
        }
    }
}

// MARK: - 4. Main Screen (13 lines)
struct MainView: View {
    @EnvironmentObject var auth: AuthManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Hello, \(auth.username)") {
                    ForEach(1...5, id: \.self) { i in
                        Text("Item \(i)")
                    }
                }
                
                Button("Logout") {
                    auth.logout()
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Home")
        }
    }
}
```

# Flow Diagram

```
┌───────────┐      Login       ┌───────────┐
│           │─────────────────▶│           │
│  LOGIN    │                  │   MAIN    │
│           │◀─────────────────│           │
└───────────┘     Logout       └───────────┘
```

# What You Need to Understand

## Core Concepts (Only 4 things!)

### 1. **State Management**
```swift
// Three key property wrappers:
@State        // View's own data
@Published    // Data in class that can change
@EnvironmentObject // Share data between views
```

### 2. **Conditional Display**
```swift
// Simple if-else logic
if auth.isLoggedIn {
    MainView()
} else {
    LoginView()
}
```

### 3. **Data Flow**
```
User Types → @State → AuthManager → @Published → Views Update
```

### 4. **View Structure**
```
App → Shows Login or Main → User interacts → State changes → View updates
```

## Complete App in 40 Lines (Even Simpler!)

```swift
import SwiftUI

// MARK: - Ultra Simple Version
@main
struct MicroApp: App {
    @State private var loggedIn = false
    @State private var username = ""
    
    var body: some Scene {
        WindowGroup {
            if loggedIn {
                MainView(loggedIn: $loggedIn, username: username)
            } else {
                LoginView(loggedIn: $loggedIn, username: $username)
            }
        }
    }
}

struct LoginView: View {
    @Binding var loggedIn: Bool
    @Binding var username: String
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Name", text: $username)
            SecureField("Pass", text: $password)
            Button("Go") {
                if !username.isEmpty { loggedIn = true }
            }
        }
        .padding()
    }
}

struct MainView: View {
    @Binding var loggedIn: Bool
    let username: String
    
    var body: some View {
        VStack {
            Text("Hi \(username)!")
            List(1...3, id: \.self) { Text("Item \($0)") }
            Button("Leave") { loggedIn = false }
                .foregroundColor(.red)
        }
    }
}
```

## Why This is Simple

1. **No complex navigation** - Just show/hide screens
2. **No networking** - Local validation only
3. **No loading states** - Instant response
4. **No error handling** - Basic validation only
5. **No persistence** - State resets on app restart

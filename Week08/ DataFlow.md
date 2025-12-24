
## 📱 Complete SwiftUI Blog Reader App

### **1. Model Layer (@ObservableObject & @Published)**

```swift
import Foundation

// MARK: - Data Model
struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// MARK: - Network Manager (ObservableObject)
class NetworkManager: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func fetchPosts() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/posts") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedPosts = try JSONDecoder().decode([Post].self, from: data)
            
            DispatchQueue.main.async {
                self.posts = decodedPosts
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch posts: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func fetchPosts(for userId: Int) async -> [Post] {
        guard let url = URL(string: "\(baseURL)/posts?userId=\(userId)") else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Post].self, from: data)
        } catch {
            return []
        }
    }
}
```

### **2. User Preferences (@EnvironmentObject)**

```swift
// MARK: - User Preferences (Global State)
class UserPreferences: ObservableObject {
    @Published var theme: AppTheme = .light
    @Published var fontSize: FontSize = .medium
    @Published var favoritePosts: Set<Int> = []
    @Published var bookmarkedPosts: [Post] = []
    @Published var selectedUserId: Int = 1
    
    enum AppTheme: String, CaseIterable {
        case light, dark, system
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    enum FontSize: String, CaseIterable {
        case small, medium, large
        
        var value: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }
    }
    
    func toggleFavorite(postId: Int) {
        if favoritePosts.contains(postId) {
            favoritePosts.remove(postId)
        } else {
            favoritePosts.insert(postId)
        }
    }
    
    func bookmarkPost(_ post: Post) {
        if !bookmarkedPosts.contains(where: { $0.id == post.id }) {
            bookmarkedPosts.append(post)
        }
    }
    
    func removeBookmark(postId: Int) {
        bookmarkedPosts.removeAll { $0.id == postId }
    }
}
```

### **3. App Entry Point with Environment Setup**

```swift
// MARK: - App Entry
@main
struct BlogReaderApp: App {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(networkManager)      // 🌍 Available globally
                .environmentObject(userPreferences)     // 🌍 Available globally
                .preferredColorScheme(userPreferences.theme.colorScheme)
                .task {
                    await networkManager.fetchPosts()
                }
        }
    }
}
```

### **4. Main Tab View Structure**

```swift
// MARK: - Main Interface
struct MainTabView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        TabView {
            // Tab 1: Posts Feed
            PostsFeedView()
                .tabItem {
                    Label("Posts", systemImage: "list.bullet")
                }
                .badge(networkManager.posts.count)
            
            // Tab 2: Favorites
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .badge(userPreferences.favoritePosts.count)
            
            // Tab 3: Bookmarks
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
                .badge(userPreferences.bookmarkedPosts.count)
            
            // Tab 4: Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
```

### **5. Posts Feed View (@ObservedObject Example)**

```swift
// MARK: - Posts Feed View
struct PostsFeedView: View {
    @ObservedObject var networkManager: NetworkManager
    @EnvironmentObject var userPreferences: UserPreferences
    
    // Local filtered state
    @State private var searchText = ""
    @State private var showingUserFilter = false
    
    init() {
        // Access environment objects in initializer
        _networkManager = EnvironmentObject()
        _userPreferences = EnvironmentObject()
    }
    
    var filteredPosts: [Post] {
        if searchText.isEmpty {
            return networkManager.posts
        } else {
            return networkManager.posts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.body.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search posts...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Loading/Error States
                if networkManager.isLoading {
                    ProgressView("Loading posts...")
                        .scaleEffect(1.5)
                        .padding()
                } else if let error = networkManager.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await networkManager.fetchPosts()
                            }
                        }
                    }
                    .padding()
                } else {
                    // Posts List
                    List(filteredPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostRowView(post: post)
                        }
                    }
                    .refreshable {
                        await networkManager.fetchPosts()
                    }
                }
            }
            .navigationTitle("Blog Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(1...10, id: \.self) { userId in
                            Button("User \(userId)") {
                                Task {
                                    userPreferences.selectedUserId = userId
                                    let userPosts = await networkManager.fetchPosts(for: userId)
                                    DispatchQueue.main.async {
                                        networkManager.posts = userPosts
                                    }
                                }
                            }
                        }
                        Divider()
                        Button("All Users") {
                            Task {
                                await networkManager.fetchPosts()
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}
```

### **6. Post Row Component**

```swift
// MARK: - Reusable Post Row Component
struct PostRowView: View {
    let post: Post
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Post number indicator
            Text("\(post.id)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(post.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("User \(post.userId)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                    
                    Spacer()
                    
                    // Favorite button
                    Button(action: {
                        userPreferences.toggleFavorite(postId: post.id)
                    }) {
                        Image(systemName: userPreferences.favoritePosts.contains(post.id) ? "heart.fill" : "heart")
                            .foregroundColor(userPreferences.favoritePosts.contains(post.id) ? .red : .gray)
                    }
                    
                    // Bookmark button
                    Button(action: {
                        userPreferences.bookmarkPost(post)
                    }) {
                        Image(systemName: userPreferences.bookmarkedPosts.contains(where: { $0.id == post.id }) ? 
                              "bookmark.fill" : "bookmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

### **7. Favorites View (Using @EnvironmentObject)**

```swift
// MARK: - Favorites View
struct FavoritesView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var userPreferences: UserPreferences
    
    var favoritePosts: [Post] {
        networkManager.posts.filter { userPreferences.favoritePosts.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            if favoritePosts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No favorites yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Tap the heart icon on any post to add it to favorites")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            } else {
                List(favoritePosts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostRowView(post: post)
                    }
                }
                .navigationTitle("Favorites")
            }
        }
    }
}
```

### **8. Settings View (Global Preferences)**

```swift
// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $userPreferences.theme) {
                        ForEach(UserPreferences.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized).tag(theme)
                        }
                    }
                    
                    Picker("Font Size", selection: $userPreferences.fontSize) {
                        ForEach(UserPreferences.FontSize.allCases, id: \.self) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }
                }
                
                Section(header: Text("Data")) {
                    HStack {
                        Text("Favorite Posts")
                        Spacer()
                        Text("\(userPreferences.favoritePosts.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bookmarked Posts")
                        Spacer()
                        Text("\(userPreferences.bookmarkedPosts.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Clear All Data") {
                        userPreferences.favoritePosts.removeAll()
                        userPreferences.bookmarkedPosts.removeAll()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("API Source")
                        Spacer()
                        Text("JSONPlaceholder")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Visit JSONPlaceholder", destination: URL(string: "https://jsonplaceholder.typicode.com")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

### **9. Post Detail View**

```swift
// MARK: - Post Detail View
struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Post #\(post.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(post.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // Quick actions
                    VStack(spacing: 10) {
                        Button(action: {
                            userPreferences.toggleFavorite(postId: post.id)
                        }) {
                            Image(systemName: userPreferences.favoritePosts.contains(post.id) ? 
                                  "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(userPreferences.favoritePosts.contains(post.id) ? .red : .primary)
                        }
                        
                        Button(action: {
                            if userPreferences.bookmarkedPosts.contains(where: { $0.id == post.id }) {
                                userPreferences.removeBookmark(postId: post.id)
                            } else {
                                userPreferences.bookmarkPost(post)
                            }
                        }) {
                            Image(systemName: userPreferences.bookmarkedPosts.contains(where: { $0.id == post.id }) ? 
                                  "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // User info
                HStack {
                    Image(systemName: "person.circle")
                    Text("User \(post.userId)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                // Post content
                Text(post.body)
                    .font(.body)
                    .lineSpacing(4)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

## 🎯 Key Concepts Demonstrated:

### **1. @ObservedObject & @Published**
- `NetworkManager` uses `@Published` properties to notify views of changes
- Multiple views observe the same data source
- Automatic UI updates when posts load or errors occur

### **2. @EnvironmentObject**
- `UserPreferences` available globally without prop drilling
- Theme, favorites, and bookmarks accessible from any view
- Changes propagate automatically across the app

### **3. Complete Data Flow**
- **API → NetworkManager (@ObservableObject) → Views**
- **User Actions → UserPreferences (@EnvironmentObject) → All Views**
- **Local State (@State) + Global State (@EnvironmentObject)**

## 🔄 Data Flow Diagram:
```
JSONPlaceholder API
        ↓
NetworkManager (@ObservableObject)
        ↓ (@Published posts)
    PostsFeedView (@ObservedObject)
        ↓ (User interaction)
UserPreferences (@EnvironmentObject)
        ↓ (Global updates)
  FavoritesView, SettingsView, etc.
```

This complete app demonstrates:
- Fetching and displaying data from your provided API
- Managing shared state with `@ObservedObject`
- Global preferences with `@EnvironmentObject`
- Filtering, searching, and user interactions
- Error handling and loading states
- Clean architecture with separation of concerns

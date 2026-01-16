# SwiftUI Lists & Navigation Workshop

## Hour 1: List and ForEach
**Simple alternative to UITableView DataSource**

### Basic List Example
```swift
import SwiftUI

struct ContentView: View {
    let fruits = ["Apple", "Banana", "Orange", "Mango"]
    
    var body: some View {
        List {
            ForEach(fruits, id: \.self) { fruit in
                Text(fruit)
            }
        }
    }
}
```

### List with Sections
```swift
List {
    Section(header: Text("Fruits")) {
        ForEach(fruits, id: \.self) { fruit in
            Text(fruit)
        }
    }
    
    Section(header: Text("Vegetables")) {
        Text("Carrot")
        Text("Broccoli")
        Text("Spinach")
    }
}
.listStyle(.insetGrouped)
```

---

## Hour 2: NavigationStack and NavigationLink
**Modern navigation for SwiftUI apps**

### Basic Navigation
```swift
struct ContentView: View {
    let fruits = ["Apple", "Banana", "Orange"]
    
    var body: some View {
        NavigationStack {
            List(fruits, id: \.self) { fruit in
                NavigationLink(fruit, value: fruit)
            }
            .navigationDestination(for: String.self) { fruit in
                FruitDetailView(fruit: fruit)
            }
            .navigationTitle("Fruits")
        }
    }
}

struct FruitDetailView: View {
    let fruit: String
    
    var body: some View {
        Text("Details for \(fruit)")
            .navigationTitle(fruit)
    }
}
```


## Hour 3: Final Project Kick-off
**Choose your path for the final project**

### Option 1: Pure SwiftUI Project
```swift
// Simple SwiftUI Task Manager Example
struct TaskManagerApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}

struct TaskListView: View {
    @State private var tasks = ["Learn SwiftUI", "Build Project", "Submit App"]
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks, id: \.self) { task in
                    Text(task)
                }
                .onDelete { indices in
                    tasks.remove(atOffsets: indices)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                Button("Add") {
                    showingAddTask = true
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(tasks: $tasks)
            }
        }
    }
}
```

### Option 2: UIKit Project
```swift
// UIKit equivalent for comparison
class TaskListViewController: UITableViewController {
    var tasks = ["Learn UIKit", "Build Project", "Submit App"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
    }
    
    @objc func addTask() {
        // UIKit implementation
    }
}
```

### Option 3: Mixed UIKit/SwiftUI
```swift
// Using UIViewControllerRepresentable
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return TaskListViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update if needed
    }
}

// Using in SwiftUI
struct MixedAppView: View {
    var body: some View {
        TabView {
            TaskListView()
                .tabItem { Label("SwiftUI", systemImage: "swift") }
            
            UIKitViewControllerWrapper()
                .tabItem { Label("UIKit", systemImage: "u.square") }
        }
    }
}
```

---

## Key Takeaways

### SwiftUI Advantages:
- **Declarative syntax** - Say what you want, not how to do it
- **Less code** - 50-75% reduction compared to UIKit
- **Live preview** - See changes instantly
- **Automatic updates** - State changes automatically update UI

### UIKit Considerations:
- **Mature ecosystem** - Battle-tested for over a decade
- **Performance** - Fine-grained control when needed
- **Existing codebases** - Many apps already use UIKit
- **Specific needs** - Certain complex customizations

### Hybrid Approach Benefits:
- **Incremental migration** - Update screens gradually
- **Best of both worlds** - Use each where they excel
- **Team flexibility** - Mix expertise levels

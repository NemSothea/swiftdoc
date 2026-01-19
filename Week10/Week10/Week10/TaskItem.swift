//
//  TaskItem.swift
//  Week10
//
//  Created by sothea007 on 19/1/26.
//
import SwiftUI

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
                    
                    Button {
                        guard !newTaskTitle.isEmpty else { return }
                        taskManager.addTask(newTaskTitle)
                        newTaskTitle = ""
                    } label: {
                        HStack {
                            // Default
                            Image(systemName: "plus.circle.fill")
                            // Customzie image
//                               Image("add")
                                
                               Text("Add")
                           }
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

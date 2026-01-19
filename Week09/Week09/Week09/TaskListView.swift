//
//  TaskListView.swift
//  Week09
//
//  Created by sothea007 on 19/1/26.
//

import SwiftUI

struct TaskListView: View {
    
    @State private var tasks = ["Learn SwiftUI", "Build Project", "Submit App"]
    @State private var showingAddTask = false
    
    
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(tasks,id:\.self) { task in
                    Text(task)
                }
            }
            .toolbar {
                Button("Add") {
                    showingAddTask = true
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
}
struct AddTaskView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Add Task")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
    //                    saveTask()
                        dismiss()
                    }
    //                .disabled(title.isEmpty)
                }
            }
        }
       
        
        
    }
}

#Preview {
    TaskListView()
}

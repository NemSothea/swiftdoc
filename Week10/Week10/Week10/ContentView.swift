//
//  ContentView.swift
//  Week10
//
//  Created by sothea007 on 19/1/26.
//

import SwiftUI

//Step 1 : Create the ObservableObject
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


struct ContentView: View {
    // Step 2 : How to use StateObject and ObservableObject
    @StateObject var userDataManager = UserDataManager()
    
    var body: some View {
        VStack {
            // Step 3 : Display data
            Text(userDataManager.username)
                .font(.headline)
            Text("Score: \(userDataManager.score)")
            Button("Login") {
                self.userDataManager.login()
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

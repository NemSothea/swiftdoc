//
//  UserViewModel.swift
//  Week10
//
//  Created by sothea007 on 19/1/26.
//
import SwiftUI

// Network layer
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

// ViewModel
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

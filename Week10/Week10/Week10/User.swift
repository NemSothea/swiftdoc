//
//  User.swift
//  Week10
//
//  Created by sothea007 on 19/1/26.
//
import SwiftUI
// Model User
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}



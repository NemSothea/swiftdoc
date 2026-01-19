//
//  NavigationListDemo.swift
//  Week09
//
//  Created by sothea007 on 19/1/26.
//

import SwiftUI

struct NavigationListDemo: View {
    
    let shoes: [String] = ["Nike Air Max 90", "Adidas Ultraboost", "Converse Chuck Taylor All Star"]
    
    var body: some View {
        // Step 1: NavigationStack
        NavigationStack {
            List(shoes,id: \.self) { shoe in
                // Step 2 : NavigationLink
                NavigationLink(destination:
                                // step 3 : FruitDetailView
                               ShoeDetailView(shoe: shoe)) {
                    Text(shoe)
                }
            }
        }
        .navigationTitle(Text("Shoe"))
       
        
    }
}

struct ShoeDetailView : View {
    
    let shoe: String
    
    var body: some View {
            Text("Detail \(shoe)")
    }
}

#Preview {
    NavigationListDemo()
}

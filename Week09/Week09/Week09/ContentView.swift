//
//  ContentView.swift
//  Week09
//
//  Created by sothea007 on 19/1/26.
//

import SwiftUI

struct ContentView: View {
    let fruits = ["Apple", "Banana", "Orange"]
    
    var body: some View {
            VStack {
                List {
                    Section(header: Text("Fruits")) {
                        ForEach(fruits, id: \.self) { fruit in
                            Text(fruit)
                        }
                    }
                }
                .listStyle(.automatic)
            }
            .padding()
        
      
    }
}




#Preview {
    ContentView()
}

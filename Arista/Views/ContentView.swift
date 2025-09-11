//
//  ContentView.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appCoordinator = AppCoordinator.shared
    
    var body: some View {
        if appCoordinator.isAuthenticated {
            TabView {
                AccountView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
                
                Text("Exercices")
                    .tabItem {
                        Label("Exercices", systemImage: "flame")
                    }
                
                Text("Sommeil")
                    .tabItem {
                        Label("Sommeil", systemImage: "moon")
                    }
            }
            .environmentObject(appCoordinator)
        } else {
            AuthenticationView()
                .environmentObject(appCoordinator)
        }
    }
}

#Preview {
    ContentView()
}

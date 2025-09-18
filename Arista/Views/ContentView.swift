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
                AccountView(viewModel: appCoordinator.makeAccountViewModel)
                    .tabItem {
                        Label("profil", systemImage: "person")
                    }

                Text("exercices")
                    .tabItem {
                        Label("exercices", systemImage: "flame")
                    }

                Text("sleep")
                    .tabItem {
                        Label("sleep", systemImage: "moon")
                    }
            }
            .environmentObject(appCoordinator)
        } else {
            AuthenticationView(viewModel: appCoordinator.makeAuthenticationViewModel)
                .environmentObject(appCoordinator)
        }
    }
}

#Preview {
    ContentView()
}

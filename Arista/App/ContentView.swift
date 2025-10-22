//
//  ContentView.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some View {
        if appCoordinator.isAuthenticated {
            NavigationStack {
                TabView {
                    if let accountVM = try? appCoordinator.makeAccountViewModel() {
                        AccountView(viewModel: accountVM)
                            .tabItem {
                                Label("profil", systemImage: "person")
                            }
                    }

                    if let exerciceVM = try? appCoordinator.makeExerciceViewModel() {
                        ExerciseView(viewModel: exerciceVM)
                            .tabItem {
                                Label("exercices", systemImage: "flame")
                            }
                    }

                    if let sleepVM = try? appCoordinator.makeSleepViewModel() {
                        SleepView(viewModel: sleepVM)
                            .tabItem {
                                Label("sleep", systemImage: "moon")
                            }
                    }
                }
                .environmentObject(appCoordinator)
            }
        } else {
            AuthenticationView(viewModel: appCoordinator.makeAuthenticationViewModel)
                .environmentObject(appCoordinator)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

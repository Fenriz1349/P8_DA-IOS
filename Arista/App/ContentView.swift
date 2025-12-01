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
        if BuildConfig.isDemo || appCoordinator.isAuthenticated {
            MainAppView()
                .environmentObject(appCoordinator)
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

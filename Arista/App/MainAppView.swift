//
//  MainAppView.swift
//  Arista
//
//  Created by Julien Cotte on 01/12/2025.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator

    var body: some View {
        guard let _ = appCoordinator.currentUser else {
            return AnyView(EmptyView())
        }

        return AnyView(
            NavigationStack {
                TabView {
                    if let accountVM = try? appCoordinator.makeUserViewModel() {
                        UserView(viewModel: accountVM)
                            .tabItem { Label("tabbar.profil", systemImage: "person") }
                    }

                    if let exerciseVM = try? appCoordinator.makeExerciceViewModel() {
                        ExerciseView(viewModel: exerciseVM)
                            .tabItem { Label("tabbar.exercices", systemImage: "flame") }
                    }

                    if let sleepVM = try? appCoordinator.makeSleepViewModel() {
                        SleepView(viewModel: sleepVM)
                            .tabItem { Label("tabbar.sleep", systemImage: "moon") }
                    }
                }
            }
        )
    }
}


#Preview {
    MainAppView()
}

//
//  AristaApp.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

@main
struct AristaApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var toastyManager = ToastyManager()

    var body: some Scene {
        WindowGroup {
            ToastyContainer(toastyManager: toastyManager) {
                ContentView()
            }
        }
    }
}

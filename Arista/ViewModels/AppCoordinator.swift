//
//  AppCoordinator.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    static let shared = AppCoordinator()
    
    @Published var currentUser: User?
    
    let dataManager: UserDataManager
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    private init() {
        self.dataManager = UserDataManager()
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        currentUser = try? dataManager.fetchLoggedUser()
    }
    
    func setCurrentUser(_ user: User) {
        currentUser = user
    }
    
    func logout() {
        do {
            try dataManager.loggedOffAllUsers()
            currentUser = nil
        } catch {
            print("Erreur de déconnexion: \(error)")
        }
    }
    
    func deleteCurrentUser() {
        guard let user = currentUser else { return }
        do {
            try dataManager.deleteUser(by: user.id)
            currentUser = nil
        } catch {
            print("Erreur de suppression: \(error)")
        }
    }
    
    func refreshCurrentUser() {
        guard let userId = currentUser?.id else { return }
        currentUser = try? dataManager.fetchUser(by: userId)
    }
}

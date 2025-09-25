//
//  AppCoordinator.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI

enum AppCoordinatorError: Error {
    case errorLogout
    case deleteCurrentUserError
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentUser: User?

    let dataManager: UserDataManager
    private let currentUserIdKey = "currentUserId"

    var isAuthenticated: Bool {
        currentUser != nil
    }

    init(dataManager: UserDataManager = UserDataManager()) {
        self.dataManager = dataManager
        restoreUserSession()
    }

    var makeAuthenticationViewModel: AuthenticationViewModel {
        AuthenticationViewModel(appCoordinator: self)
    }

    func makeAccountViewModel() throws -> AccountViewModel {
        return try AccountViewModel(appCoordinator: self)
    }

    func makeEditAccountViewModel() throws -> EditAccountViewModel {
        return try EditAccountViewModel(appCoordinator: self)
    }

    private func restoreUserSession() {
        if let userIdString = UserDefaults.standard.string(forKey: currentUserIdKey),
           let userId = UUID(uuidString: userIdString) {

            do {
                let user = try dataManager.fetchUser(by: userId)
                if user.isLogged {
                    currentUser = user
                } else {
                    clearStoredSession()
                }
            } catch {
                clearStoredSession()
            }
        }
    }

    private func saveUserSession(_ userId: UUID) {
        UserDefaults.standard.set(userId.uuidString, forKey: currentUserIdKey)
    }

    private func clearStoredSession() {
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
    }

    func login(id: UUID) throws {
        try dataManager.loggedIn(id: id)
        currentUser = try dataManager.fetchUser(by: id)
        saveUserSession(id)
    }

    func logout() throws {
        try dataManager.loggedOffAllUsers()
        currentUser = nil
        clearStoredSession()
    }

    func deleteCurrentUser() throws {
        guard let user = currentUser else { return }
        try dataManager.deleteUser(by: user.id)
        currentUser = nil
        clearStoredSession()
    }
    
    func isEmailAlreadyUsed(_ email: String) -> Bool {
        return dataManager.fetchAllUsers().contains { $0.email == email }
    }
}

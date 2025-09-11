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
    static let shared = AppCoordinator()

    @Published var currentUser: User?

    let dataManager: UserDataManager

    var isAuthenticated: Bool {
        currentUser != nil
    }

    private init() {
        self.dataManager = UserDataManager()
    }

    init(dataManager: UserDataManager) {
        self.dataManager = dataManager
    }

    func login(id: UUID) throws {
        try dataManager.loggedIn(id: id)
        currentUser = try dataManager.fetchUser(by: id)
    }

    func logout() throws {
        try dataManager.loggedOffAllUsers()
        currentUser = nil
    }

    func deleteCurrentUser() throws {
        guard let user = currentUser else { return }
        try dataManager.deleteUser(by: user.id)
        currentUser = nil
    }
}

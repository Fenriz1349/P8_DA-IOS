//
//  AppCoordinator.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentUser: User?
    static let demoEmail = "demo@arista.app"

    let dataManager: UserDataManager
    private let currentUserIdKey = "currentUserId"

    /// Initializes the application coordinator and restores the previous user session if available.
    /// - Parameter dataManager: The user data manager for persistence operations. Defaults to a new instance.
    init(dataManager: UserDataManager = UserDataManager()) {
        self.dataManager = dataManager
        ensureDemoUserExists()
        restoreUserSession()
    }

    private func ensureDemoUserExists() {
        let users = dataManager.fetchAllUsers()

        if users.contains(where: { $0.email == AppCoordinator.demoEmail }) { return }

        do {
            let demoUser = try dataManager.createUser(
                email: AppCoordinator.demoEmail,
                password: "1234",
                firstName: "Bruce",
                lastName: "Wayne"
            )

            try dataManager.loggedIn(id: demoUser.id)
            currentUser = demoUser
            UserDefaults.standard.set(demoUser.id.uuidString, forKey: currentUserIdKey)

            print("✅ Demo user created and logged in")
        } catch {
            print("⚠️ Failed to create demo user: \(error)")
        }
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    /// Validates and returns the currently logged-in user.
    /// - Returns: The current user.
    /// - Throws: `UserDataManagerError.noLoggedUser` if no user is currently logged in.
    func validateCurrentUser() throws -> User {
        guard let currentUser = currentUser else {
            throw UserDataManagerError.noLoggedUser
        }
        return currentUser
    }

    var makeAuthenticationViewModel: AuthenticationViewModel {
        AuthenticationViewModel(appCoordinator: self)
    }

    /// Creates a new UserViewModel instance.
    /// - Returns: A UserViewModel linked to this coordinator.
    /// - Throws: `UserDataManagerError.noLoggedUser` if no user is currently logged in.
    func makeUserViewModel() throws -> UserViewModel {
        return try UserViewModel(appCoordinator: self)
    }

    /// Creates a new SleepViewModel instance.
    /// - Returns: A SleepViewModel linked to this coordinator.
    /// - Throws: `UserDataManagerError.noLoggedUser` if no user is currently logged in.
    func makeSleepViewModel() throws -> SleepViewModel {
        return try SleepViewModel(appCoordinator: self)
    }

    /// Creates a new ExerciseViewModel instance.
    /// - Returns: An ExerciseViewModel linked to this coordinator.
    /// - Throws: `UserDataManagerError.noLoggedUser` if no user is currently logged in.
    func makeExerciceViewModel() throws -> ExerciseViewModel {
        return try ExerciseViewModel(appCoordinator: self)
    }

    /// Restores the user session from UserDefaults.
    /// Attempts to retrieve the user ID from persistent storage and load the user data.
    /// If the user is still logged in, the session is restored; otherwise, it is cleared.
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

    /// Saves the user ID to UserDefaults to persist the session.
    /// - Parameter userId: The unique identifier of the user to save.
    private func saveUserSession(_ userId: UUID) {
        UserDefaults.standard.set(userId.uuidString, forKey: currentUserIdKey)
    }

    /// Clears the session data stored in UserDefaults.
    /// Removes the saved user ID, effectively resetting the session.
    private func clearStoredSession() {
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
    }

    /// Logs in a user with the specified ID.
    /// - Parameter id: The unique identifier of the user to log in.
    /// - Throws: An error if the login fails or if the user is not found.
    func login(id: UUID) throws {
        try dataManager.loggedIn(id: id)
        currentUser = try dataManager.fetchUser(by: id)
        saveUserSession(id)
    }

    /// Logs out all users from the application.
    /// - Throws: An error if the logout fails.
    func logout() throws {
        try dataManager.loggedOffAllUsers()
        currentUser = nil
        clearStoredSession()
    }

    /// Deletes the currently logged-in user from the database.
    /// - Throws: An error if the deletion fails.
    func deleteCurrentUser() throws {
        guard let user = currentUser else { return }
        try dataManager.deleteUser(by: user.id)
        currentUser = nil
        clearStoredSession()
    }

    /// Checks if an email address is already used by an existing user.
    /// - Parameter email: The email address to check.
    /// - Returns: `true` if the email is already in use, `false` otherwise.
    func isEmailAlreadyUsed(_ email: String) -> Bool {
        return dataManager.fetchAllUsers().contains { $0.email == email }
    }
}

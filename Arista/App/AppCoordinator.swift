//
//  AppCoordinator.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentUser: User

    let dataManager: UserDataManager

    /// Initializes the application coordinator and restores the previous user session if available.
    /// - Parameter dataManager: The user data manager for persistence operations. Defaults to a new instance.
    init(dataManager: UserDataManager = UserDataManager()) {
        self.dataManager = dataManager
        self.currentUser = dataManager.getOrCreateUser()
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
}

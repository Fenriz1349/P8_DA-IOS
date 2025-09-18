//
//  EditAccountViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 16/09/2025.
//

import Foundation

@MainActor

final class EditAccountViewModel: ObservableObject {
    private let appCoordinator: AppCoordinator

    var currentUser: User? {
        appCoordinator.currentUser
    }

    init(appCoordinator: AppCoordinator ) {
        self.appCoordinator = appCoordinator
    }

    private func builder() throws -> UserUpdateBuilder {
        guard let user = currentUser else {
            throw AppCoordinatorError.errorLogout
        }
        return UserUpdateBuilder(user: user, dataManager: appCoordinator.dataManager)
    }

    // MARK: - Update Methods
    func updateFirstName(_ value: String) throws {
        try builder().firstName(value).save()
    }

    func updateLastName(_ value: String) throws {
        try builder().lastName(value).save()
    }

    func updatePassword(_ value: String) throws {
        try builder().password(value).save()
    }

    func updateGender(_ value: Gender) throws {
        try builder().gender(value).save()
    }

    func updateCalorieGoal(_ value: Int) throws {
        try builder().calorieGoal(value).save()
    }

    func updateSleepGoal(_ value: Int) throws {
        try builder().sleepGoal(value).save()
    }

    func updateWaterGoal(_ value: Int) throws {
        try builder().waterGoal(value).save()
    }

    func updateHeight(_ value: Int) throws {
        try builder().height(value).save()
    }

    func updateWeight(_ value: Int) throws {
        try builder().weight(value).save()
    }

    func updateBirthDate(_ value: Date) throws {
        try builder().birthDate(value).save()
    }
    
    func deleteAccount() throws {
        try appCoordinator.deleteCurrentUser()
    }
}

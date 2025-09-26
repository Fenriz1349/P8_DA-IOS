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
    private let user: User
    @Published var toastyManager: ToastyManager?

    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var selectedGender: Gender = .other
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var calorieGoal: String = ""
    @Published var sleepGoal: String = ""
    @Published var waterGoal: String = ""
    @Published var birthdate: Date = Date()

    init(appCoordinator: AppCoordinator) throws {
        self.appCoordinator = appCoordinator
        self.user = try appCoordinator.validateCurrentUser()
        loadUserData()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    private func loadUserData() {
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.selectedGender = user.genderEnum
        self.height = user.hasHeight ? String(user.height) : ""
        self.weight = user.hasWeight ? String(user.weight) : ""
        self.calorieGoal = String(user.calorieGoal)
        self.sleepGoal = String(user.sleepGoal)
        self.waterGoal = String(user.waterGoal)
        self.birthdate = user.birthdate ?? Date()
    }

    private func builder() throws -> UserUpdateBuilder {
        return UserUpdateBuilder(user: user, dataManager: appCoordinator.dataManager)
    }

    // MARK: - Update Methods

    func saveChanges() {
        do {
            let builder = try builder()
            var hasChanges = false

            if firstName != user.firstName {
                try builder.firstName(firstName)
                hasChanges = true
            }

            if lastName != user.lastName {
                try builder.lastName(lastName)
                hasChanges = true
            }

            if selectedGender != user.genderEnum {
                builder.gender(selectedGender)
                hasChanges = true
            }

            if !Calendar.current.isDate(birthdate, inSameDayAs: user.birthdate ?? Date()) {
                builder.birthDate(birthdate)
                hasChanges = true
            }

            if let heightValue = Int(height), heightValue > 0, heightValue != user.height {
                try builder.height(heightValue)
                hasChanges = true
            }

            if let weightValue = Int(weight), weightValue > 0, weightValue != user.weight {
                try builder.weight(weightValue)
                hasChanges = true
            }

            if let calorieValue = Int(calorieGoal), calorieValue > 0, calorieValue != user.calorieGoal {
                try builder.calorieGoal(calorieValue)
                hasChanges = true
            }

            if let sleepValue = Int(sleepGoal), sleepValue > 0, sleepValue != user.sleepGoal {
                try builder.sleepGoal(sleepValue)
                hasChanges = true
            }

            if let waterValue = Int(waterGoal), waterValue > 0, waterValue != user.waterGoal {
                try builder.waterGoal(waterValue)
                hasChanges = true
            }

            if hasChanges {
                try builder.save()
            }
        } catch {
            toastyManager?.showError(error)
        }
    }

    func deleteAccount() {
        do {
            try appCoordinator.deleteCurrentUser()
        } catch {
            toastyManager?.showError(error)
        }
    }
}

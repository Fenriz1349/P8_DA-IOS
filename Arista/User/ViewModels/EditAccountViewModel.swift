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

    /// Update Methods

    func saveChanges() {
        guard hasUserChanges() else { return }

        do {
            let builder = try builder()

            try builder.firstName(firstName)
                .lastName(lastName)
                .gender(selectedGender)
                .birthDate(birthdate)
                .height(Int(height) ?? 0)
                .weight(Int(weight) ?? 0)
                .calorieGoal(Int(calorieGoal) ?? 0)
                .sleepGoal(Int(sleepGoal) ?? 0)
                .waterGoal(Int(waterGoal) ?? 0)
                .save()
        } catch {
            toastyManager?.showError(error)
        }
    }

    private func hasUserChanges() -> Bool {
        return firstName != user.firstName ||
               lastName != user.lastName ||
               selectedGender != user.genderEnum ||
               !Calendar.current.isDate(birthdate, inSameDayAs: user.birthdate ?? Date()) ||
               (Int(height) ?? 0) != user.height ||
               (Int(weight) ?? 0) != user.weight ||
               (Int(calorieGoal) ?? 0) != user.calorieGoal ||
               (Int(sleepGoal) ?? 0) != user.sleepGoal ||
               (Int(waterGoal) ?? 0) != user.waterGoal
    }

    func deleteAccount() {
        do {
            try appCoordinator.deleteCurrentUser()
        } catch {
            toastyManager?.showError(error)
        }
    }
}

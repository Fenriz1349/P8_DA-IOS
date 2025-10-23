//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

@MainActor
final class UserViewModel: ObservableObject {
    /// Dependencies
    private let appCoordinator: AppCoordinator
    private let dataManager: UserDataManager
    private(set) var user: User

    @Published var toastyManager: ToastyManager?

    /// UI / Published Properties
    @Published var showEditModal = false
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var calorieGoal = ""
    @Published var sleepGoal = ""
    @Published var waterGoal = ""

    /// Initialization
    init(appCoordinator: AppCoordinator, dataManager: UserDataManager? = nil) throws {
        self.appCoordinator = appCoordinator
        self.dataManager = dataManager ?? UserDataManager()
        self.user = try appCoordinator.validateCurrentUser()
        loadUser()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    func loadUser() {
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        calorieGoal = String(user.calorieGoal)
        sleepGoal = String(user.sleepGoal)
        waterGoal = String(user.waterGoal)
    }

    func saveChanges() {
        do {
            let builder = UserUpdateBuilder(user: user, dataManager: dataManager)
            try builder
                .firstName(firstName)
                .lastName(lastName)
                .calorieGoal(Int(calorieGoal) ?? 0)
                .sleepGoal(Int(sleepGoal) ?? 0)
                .waterGoal(Int(waterGoal) ?? 0)
                .save()

            showEditModal = false
            loadUser()
        } catch {
            toastyManager?.showError(error)
        }
    }

    func openEditModal() {
        showEditModal = true
    }

    func closeEditModal() {
        showEditModal = false
    }

    func logout() {
        do {
            try appCoordinator.logout()
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

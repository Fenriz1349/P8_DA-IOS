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
    private let goalDataManager: GoalDataManager
    private(set) var user: User

    @Published var toastyManager: ToastyManager?

    /// UI / Published Properties
    @Published var showEditModal = false
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var calorieGoal = ""
    @Published var sleepGoal = ""
    @Published var waterGoal = ""
    @Published var stepsGoal = ""
    
    /// Daily Goals
    @Published var currentWater: Double = 0 {
        didSet { updateWater() }
    }
    @Published var currentSteps: Double = 0 {
        didSet { updateSteps() }
    }

    /// Initialization
    init(
        appCoordinator: AppCoordinator,
        dataManager: UserDataManager? = nil,
        goalDataManager: GoalDataManager? = nil
    ) throws {
        self.appCoordinator = appCoordinator
        self.dataManager = dataManager ?? UserDataManager()
        self.goalDataManager = goalDataManager ?? GoalDataManager()
        self.user = try appCoordinator.validateCurrentUser()
        loadUser()
        loadTodayGoal()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    func loadUser() {
        firstName = user.firstName
        lastName = user.lastName
        calorieGoal = String(user.calorieGoal)
        sleepGoal = String(user.sleepGoal)
        waterGoal = String(user.waterGoal)
        stepsGoal = String(user.stepsGoal)
    }

    func loadTodayGoal() {
        do {
            if let todayGoal = try goalDataManager.fetchGoal(for: user) {
                currentWater = Double(todayGoal.totalWater)
                currentSteps = Double(todayGoal.totalSteps)
            }
        } catch {
            toastyManager?.showError(error)
        }
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
    
    /// Goal Updates
    private func updateWater() {
        Task {
            do {
                _ = try goalDataManager.updateWater(for: user, newWater: Int16(currentWater))
            } catch {
                print("Error updating water: \(error)")
            }
        }
    }

    private func updateSteps() {
        Task {
            do {
                _ = try goalDataManager.updateSteps(for: user, newSteps: Int32(currentSteps))
            } catch {
                print("Error updating steps: \(error)")
            }
        }
    }
}

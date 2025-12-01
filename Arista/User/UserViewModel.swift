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
    private let sleepDataManager: SleepDataManager
    private(set) var user: User

    @Published var toastyManager: ToastyManager?

    /// UI / Published Properties
    @Published var showingResetAlert = false
    @Published var showEditModal = false
    @Published var isDeleted = false
    let alertMessage = String(localized: "user.deleteAccount.alert.message")

    /// Edit form fields
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var calorieGoal: Int = 2000
    @Published var sleepGoal: Int = 480
    @Published var waterGoal: Int = 25
    @Published var stepsGoal: Int = 10000

    /// Daily Goals
    @Published var currentWater: Double = 0 { didSet { updateWater() }}
    @Published var currentSteps: Double = 0 { didSet { updateSteps() }}

    /// Cached sleep data
    @Published private(set) var cachedSleepCycles: [SleepCycleDisplay] = []

    /// Computed for display
    var userDisplay: UserDisplay {
        user.toDisplay()
    }

    /// Demo Protections
    var canEditIdentity: Bool {
        !BuildConfig.isDemo
    }

    var canManageAccount: Bool {
        !BuildConfig.isDemo
    }

    var todayCalories: Int {
        do {
            if let todayGoal = try goalDataManager.fetchGoal(for: user) {
                return todayGoal.toDisplay().totalCalories
            }
            return 0
        } catch {
            toastyManager?.showError(error)
            return 0
        }
    }

    var lastSevenDaysCalories: [DayCalories] {
        do {
            let goals = try goalDataManager.fetchLastWeekGoals(for: user)
            let goalsDisplay = Goal.mapToDisplay(from: goals).toDayCalories()

            let today = Calendar.current.startOfDay(for: Date())
            return (0..<7).compactMap { offset in
                guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else {
                    return nil
                }

                let dayGoal = goalsDisplay.first {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }

                return dayGoal ?? DayCalories(date: date, calories: 0)
            }.reversed()

        } catch {
            toastyManager?.showError(error)
            return []
        }
    }

    var lastWeekSleepCycles: [SleepCycleDisplay] {
        cachedSleepCycles
    }

    var averageSleepDuration: TimeInterval {
        let completedCycles = lastWeekSleepCycles.filter { $0.dateEnding != nil }
        guard !completedCycles.isEmpty else { return 0 }

        let totalDuration = completedCycles.reduce(0.0) { sum, cycle in
            guard let endDate = cycle.dateEnding else { return sum }
            return sum + cycle.dateStart.duration(to: endDate)
        }

        return totalDuration / Double(completedCycles.count)
    }

    var averageSleepQuality: Double {
        let completedCycles = lastWeekSleepCycles.filter { $0.dateEnding != nil }
        guard !completedCycles.isEmpty else { return 0 }

        let totalQuality = completedCycles.reduce(0) { $0 + $1.quality }
        return Double(totalQuality) / Double(completedCycles.count)
    }

    var sleepMetrics: SleepMetrics {
        SleepMetrics(
            averageDuration: averageSleepDuration,
            sleepGoal: Int(user.sleepGoal),
            averageQuality: averageSleepQuality
        )
    }

    /// Initializes the ViewModel with required dependencies and validates the current user
    /// - Parameters:
    ///   - appCoordinator: The app coordinator managing navigation and user state
    ///   - dataManager: Manager for user data operations
    ///   - goalDataManager: Manager for goal data operations
    ///   - sleepDataManager: Manager for sleep data operations
    /// - Throws: Error if no valid user is logged in
    init(
        appCoordinator: AppCoordinator,
        dataManager: UserDataManager? = nil,
        goalDataManager: GoalDataManager? = nil,
        sleepDataManager: SleepDataManager? = nil
    ) throws {
        self.appCoordinator = appCoordinator
        self.dataManager = appCoordinator.dataManager
        self.goalDataManager = goalDataManager ?? GoalDataManager()
        self.sleepDataManager = sleepDataManager ?? SleepDataManager()
        self.user = try appCoordinator.validateCurrentUser()
        loadTodayGoal()
        loadSleepData()
    }

    /// Configures the toasty notification manager
    /// - Parameter toastyManager: The ToastyManager instance to use for notifications
    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    /// Loads user data into the edit form fields
    func loadUserForEditing() {
        firstName = user.firstName
        lastName = user.lastName
        calorieGoal = Int(user.calorieGoal)
        sleepGoal = Int(user.sleepGoal)
        waterGoal = Int(user.waterGoal)
        stepsGoal = Int(user.stepsGoal)
    }

    /// Loads today's goal data (water and steps progress)
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

    /// Loads recent sleep cycles data for the user
    func loadSleepData() {
        do {
            let cycles = try sleepDataManager.fetchRecentSleepCycles(for: user)
            cachedSleepCycles = SleepCycle.mapToDisplay(from: cycles)
        } catch {
            toastyManager?.showError(error)
            cachedSleepCycles = []
        }
    }

    /// Refreshes all user-related data (goals and sleep)
    func refreshData() {
        loadTodayGoal()
        loadSleepData()
    }

    /// Saves changes made in the edit form to the user profile
    func saveChanges() {
        do {
            let builder = UserUpdateBuilder(user: user, dataManager: dataManager)
            try builder
                .firstName(firstName)
                .lastName(lastName)
                .calorieGoal(calorieGoal)
                .sleepGoal(sleepGoal)
                .waterGoal(waterGoal)
                .stepsGoal(stepsGoal)
                .save()

            showEditModal = false
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Opens the edit profile modal and loads current user data
    func openEditModal() {
        loadUserForEditing()
        showEditModal = true
    }

    /// Closes the edit profile modal
    func closeEditModal() {
        showEditModal = false
    }

    /// Logs out the current user
    func logout() {
        do {
            try appCoordinator.logout()
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Deletes the current user's account permanently
    func deleteAccount() {
        do {
            try appCoordinator.deleteCurrentUser()
            isDeleted = true
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Updates the water consumption for the current day
    private func updateWater() {
        Task {
            do {
                _ = try goalDataManager.updateWater(for: user, newWater: Int16(currentWater))
            } catch {
                toastyManager?.showError(error)
            }
        }
    }

    /// Updates the steps count for the current day
    private func updateSteps() {
        Task {
            do {
                _ = try goalDataManager.updateSteps(for: user, newSteps: Int32(currentSteps))
            } catch {
                toastyManager?.showError(error)
            }
        }
    }
}

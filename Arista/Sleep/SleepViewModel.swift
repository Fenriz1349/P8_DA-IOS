//
//  SleepViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import Foundation
import CustomTextFields

enum SleepTrackingState: Equatable {
    case none
    case active(SleepCycleDisplay)
    case completed(SleepCycleDisplay)

    var isActive: Bool {
        if case .active = self { return true }
        return false
    }
}

@MainActor
final class SleepViewModel: ObservableObject {

    /// Dependencies
    private let appCoordinator: AppCoordinator
    private let sleepDataManager: SleepDataManager
    let title = "sleep.modal.quality".localized
    let currentUser: User

    /// UI / Published Properties
    @Published var toastyManager: ToastyManager?
    @Published var currentCycle: SleepCycleDisplay?
    @Published var editingCycle: SleepCycleDisplay?
    @Published var historyCycles: [SleepCycleDisplay] = []
    @Published var selectedQuality: Int = 0
    @Published var showEditModal = false

    /// Manual Entry
    @Published var manualStartDate: Date = Date()
    @Published var manualEndDate: Date = Date()
    @Published var dateValidationState: ValidationState = .neutral

    /// Computed State
    var currentState: SleepTrackingState {
        guard let cycle = currentCycle else { return .none }
        return cycle.dateEnding == nil ? .active(cycle) : .completed(cycle)
    }

    var dateErrorMessage: String? {
        guard dateValidationState == .invalid else { return nil }
        return "error.sleep.invalidDateInterval".localized
    }

    /// Initializes the ViewModel with required dependencies and validates the current user
    /// - Parameters:
    ///   - appCoordinator: The app coordinator managing navigation and user state
    ///   - sleepDataManager: Manager for sleep data operations
    /// - Throws: Error if no valid user is logged in
    init(appCoordinator: AppCoordinator, sleepDataManager: SleepDataManager? = nil) throws {
        self.appCoordinator = appCoordinator
        self.sleepDataManager = sleepDataManager ?? SleepDataManager()
        self.currentUser = try appCoordinator.validateCurrentUser()
        reloadAllData()
    }

    /// Configures the toasty notification manager
    /// - Parameter toastyManager: The ToastyManager instance to use for notifications
    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    /// Reloads all sleep cycle data for the current user
    /// Fetches recent sleep cycles and separates current cycle from history
    func reloadAllData() {
        do {
            let cycles = try sleepDataManager.fetchRecentSleepCycles(for: currentUser)
            let displays = SleepCycle.mapToDisplay(from: cycles)

            currentCycle = displays.first
            historyCycles = Array(displays.dropFirst())

        } catch {
            toastyManager?.showError(error)
            currentCycle = nil
            historyCycles = []
        }
    }

    /// Validates the manual entry dates
    /// Sets validation state to valid if end date is after start date, invalid otherwise
    func validateDates() {
        do {
            try Date.validateInterval(from: manualStartDate, to: manualEndDate)
            dateValidationState = .valid
        } catch {
            dateValidationState = .invalid
        }
    }

    /// Resets the date validation state to neutral
    func resetValidation() {
        dateValidationState = .neutral
    }

    /// Starts a new sleep cycle for the current user
    /// - Parameter startDate: The start date of the sleep cycle (defaults to current date)
    func startSleepCycle(startDate: Date = Date()) {
        do {
            _ = try sleepDataManager.startSleepCycle(for: currentUser, startDate: startDate)
            reloadAllData()
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Ends the active sleep cycle for the current user
    /// - Parameter endDate: The end date of the sleep cycle (defaults to current date)
    func endSleepCycle(endDate: Date = Date()) {
        do {
            _ = try sleepDataManager.endSleepCycle(for: currentUser,
                                                   endDate: endDate,
                                                   quality: selectedQuality)
            reloadAllData()
            selectedQuality = 0
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Opens the edit modal for a sleep cycle
    /// - Parameter cycle: The cycle to edit, or nil to create a new manual entry
    func openEditModal(for cycle: SleepCycleDisplay?) {
        let cycle = cycle ?? SleepCycleDisplay(
            id: UUID(),
            dateStart: Date().addingTimeInterval(-8 * 3600),
            dateEnding: Date(),
            quality: 5
        )
        editingCycle = cycle
        manualStartDate = cycle.dateStart
        manualEndDate = cycle.dateEnding ?? Date()
        selectedQuality = cycle.quality
        resetValidation()
        showEditModal = true
    }

    /// Cancels the edit operation and closes the modal
    func cancelEdit() {
        showEditModal = false
        editingCycle = nil
        resetValidation()
    }

    /// Saves the sleep cycle (creates new or updates existing)
    /// Validates dates before saving and reloads data on success
    func saveCycle() {
        validateDates()

        do {
            if let editing = editingCycle {
                try sleepDataManager.updateSleepCycle(
                    by: editing.id,
                    startDate: manualStartDate,
                    endDate: manualEndDate,
                    quality: selectedQuality)
            } else {
                _ = try sleepDataManager.startSleepCycle(for: currentUser, startDate: manualStartDate)
                _ = try sleepDataManager.endSleepCycle(for: currentUser,
                                                       endDate: manualEndDate,
                                                       quality: selectedQuality)
            }

            reloadAllData()
            showEditModal = false
            editingCycle = nil
            resetValidation()
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Deletes a sleep cycle from history
    /// - Parameter cycleDisplay: The cycle display to delete
    func deleteHistoryCycle(_ cycleDisplay: SleepCycleDisplay) {
        do {
            let cycles = try sleepDataManager.fetchSleepCycles(for: currentUser)
            if let target = cycles.first(where: { $0.id == cycleDisplay.id }) {
                try sleepDataManager.deleteSleepCycle(target)
                reloadAllData()
            }
        } catch {
            toastyManager?.showError(error)
        }
    }
}

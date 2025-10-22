//
//  SleepViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import Foundation

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
    let title = "Qualité"
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

    /// Computed State
    var currentState: SleepTrackingState {
        guard let cycle = currentCycle else { return .none }
        return cycle.dateEnding == nil ? .active(cycle) : .completed(cycle)
    }

    /// Initialization
    init(appCoordinator: AppCoordinator, sleepDataManager: SleepDataManager? = nil) throws {
        self.appCoordinator = appCoordinator
        self.sleepDataManager = sleepDataManager ?? SleepDataManager()
        self.currentUser = try appCoordinator.validateCurrentUser()
        reloadAllData()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    /// Data Loading
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

    /// Toggle Actions
    func startSleepCycle(startDate: Date = Date()) {
        do {
            _ = try sleepDataManager.startSleepCycle(for: currentUser, startDate: startDate)
            reloadAllData()
        } catch {
            toastyManager?.showError(error)
        }
    }

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

    /// Edit Cycle
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
        showEditModal = true
    }

    func cancelEdit() {
        showEditModal = false
        editingCycle = nil
    }

    /// Save
    func saveCycle() {
        do {
            try Date.validateInterval(from: manualStartDate, to: manualEndDate)

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
        } catch {
            toastyManager?.showError(error)
        }
    }

    /// Delete
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

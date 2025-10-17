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

enum SleepEntryMode {
    case toggle
    case manual
}

@MainActor
final class SleepViewModel: ObservableObject {

    /// Dependencies
    private let appCoordinator: AppCoordinator
    private let sleepDataManager: SleepDataManager
    private let currentUserId: UUID
    let currentUser: User

    /// UI / Published Properties
    @Published var toastyManager: ToastyManager?
    @Published var currentCycle: SleepCycleDisplay?
    @Published var historyCycles: [SleepCycleDisplay] = []
    @Published var selectedQuality: Int16 = 0
    @Published var showManualEntry = false
    @Published var isEditingLastCycle = false
    @Published var entryMode: SleepEntryMode = .toggle

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
        self.currentUserId = currentUser.id
        reloadAllData()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    /// Data Loading
    func reloadAllData() {
        do {
            let cycles = try sleepDataManager.fetchSleepCycles(for: currentUser, limit: 8)
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

    /// Manual Entry
    func showManualEntryMode() {
        entryMode = .manual
        showManualEntry = true

        let now = Date()
        manualEndDate = now
        manualStartDate = now.addingTimeInterval(-8 * 3600)
    }

    func saveManualEntry() {
        do {
            try Date.validateInterval(from: manualStartDate, to: manualEndDate)

            _ = try sleepDataManager.startSleepCycle(for: currentUser,
                                                     startDate: manualStartDate)
            _ = try sleepDataManager.endSleepCycle(for: currentUser,
                                                   endDate: manualEndDate,
                                                   quality: selectedQuality)

            reloadAllData()
            showManualEntry = false
            entryMode = .toggle

        } catch {
            toastyManager?.showError(error)
        }
    }

    func cancelManualEntry() {
        showManualEntry = false
        isEditingLastCycle = false
        entryMode = .toggle
    }

    /// Edit Cycle
    func editCurrentCycle() {
        guard let cycle = currentCycle, cycle.dateEnding != nil else { return }

        isEditingLastCycle = true
        entryMode = .manual
        showManualEntry = true

        manualStartDate = cycle.dateStart
        manualEndDate = cycle.dateEnding ?? Date()
        selectedQuality = cycle.quality
    }

    func saveEditedCycle() {
        guard let cycleDisplay = currentCycle else { return }

        do {
            try Date.validateInterval(from: manualStartDate, to: manualEndDate)

            let cycles = try sleepDataManager.fetchSleepCycles(for: currentUser)
            if let target = cycles.first(where: { $0.id == cycleDisplay.id }) {
                _ = try sleepDataManager.updateSleepCycle(
                    target,
                    startDate: manualStartDate,
                    endDate: manualEndDate,
                    quality: selectedQuality
                )
            }

            reloadAllData()
            isEditingLastCycle = false
            showManualEntry = false
            entryMode = .toggle
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


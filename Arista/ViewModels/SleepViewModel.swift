//
//  SleepViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import Foundation

enum SleepTrackingState: Equatable {
    case none
    case active(SleepCycle)
    case completed(SleepCycle)
}

enum SleepEntryMode {
    case toggle
    case manual
}

@MainActor
final class SleepViewModel: ObservableObject {

    // MARK: - Dependencies
    private let appCoordinator: AppCoordinator
    private let sleepDataManager: SleepDataManager
    let currentUser: User
    @Published var toastyManager: ToastyManager?

    // MARK: - Published Properties
    @Published var lastCycle: SleepCycle?
    @Published var entryMode: SleepEntryMode = .toggle
    @Published var showManualEntry: Bool = false
    @Published var isEditingLastCycle: Bool = false

    // MARK: - Manual Entry Properties
    @Published var manualStartDate: Date = Date()
    @Published var manualEndDate: Date = Date()

    // MARK: - Computed Properties
    var currentState: SleepTrackingState {
        guard let cycle = lastCycle else { return .none }
        return cycle.dateEnding == nil ? .active(cycle) : .completed(cycle)
    }

    // MARK: - Initialization
    init(appCoordinator: AppCoordinator, sleepDataManager: SleepDataManager? = nil) throws {
        self.appCoordinator = appCoordinator
        self.sleepDataManager = sleepDataManager ?? SleepDataManager()
        self.currentUser = try appCoordinator.validateCurrentUser()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    // MARK: - Data Loading
    func loadLastCycle() {
        do {
            let cycles = try sleepDataManager.fetchSleepCycles(for: currentUser)
            lastCycle = cycles.first
        } catch {
            toastyManager?.showError(error)
        }
    }

    // MARK: - Toggle Actions
    func startSleepCycleWithToggle(startDate: Date = Date()) {
        do {
            let cycle = try sleepDataManager.startSleepCycle(for: currentUser, startDate: startDate)
            lastCycle = cycle
        } catch {
            toastyManager?.showError(error)
        }
    }

    func endSleepCycleWithToggle(endDate: Date = Date(), quality: Int16? = nil) {
        do {
            let cycle = try sleepDataManager.endSleepCycle(for: currentUser, endDate: endDate, quality: quality)
            lastCycle = cycle
        } catch {
            toastyManager?.showError(error)
        }
    }

    // MARK: - Manual Entry Actions
    func showManualEntryMode() {
        entryMode = .manual
        showManualEntry = true
        
        let now = Date()
        manualEndDate = now
        manualStartDate = now.addingTimeInterval(-8 * 3600)
    }
    
    func saveManualEntry(quality: Int16? = nil) {
        do {
            try Date.validateInterval(from: manualStartDate, to: manualEndDate)
            
            let cycle = try sleepDataManager.startSleepCycle(for: currentUser, startDate: manualStartDate)
            let completedCycle = try sleepDataManager.endSleepCycle(for: currentUser, endDate: manualEndDate, quality: quality)

            lastCycle = completedCycle
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

    // MARK: - Edit Last Cycle
    func editLastCycle() {
        guard let cycle = lastCycle, cycle.dateEnding != nil else { return }

        isEditingLastCycle = true
        entryMode = .manual
        showManualEntry = true

        manualStartDate = cycle.dateStart
        manualEndDate = cycle.dateEnding ?? Date()
    }

    func saveEditedCycle(quality: Int16? = nil) {
        guard let cycle = lastCycle else { return }
        
        do {
            try Date.validateInterval(from: manualStartDate, to: manualEndDate)
            
            cycle.dateStart = manualStartDate
            cycle.dateEnding = manualEndDate
            
            if let quality = quality {
                try sleepDataManager.updateSleepQuality(for: cycle, quality: quality)
            }
            
            loadLastCycle()
            
            isEditingLastCycle = false
            showManualEntry = false
            entryMode = .toggle
            
        } catch {
            toastyManager?.showError(error)
        }
    }
}

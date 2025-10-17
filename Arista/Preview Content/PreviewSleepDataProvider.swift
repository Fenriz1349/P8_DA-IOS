//
//  PreviewSleepDataProvider.swift
//  Arista
//
//  Created by Julien Cotte on 17/10/2025.
//

import Foundation
import CoreData

@MainActor
struct PreviewSleepDataProvider {

    // MARK: - Convenience context
    private static var context: NSManagedObjectContext {
        PreviewDataProvider.PreviewContext
    }

    private static var user: User {
        PreviewDataProvider.sampleUser
    }

    private static var calendar: Calendar { .current }

    // MARK: - Base ViewModel Factory
    static func makePreviewViewModel() -> SleepViewModel {
        let mockCoordinator = PreviewDataProvider.sampleCoordinator

        let mockManager = SleepDataManager(container: PreviewDataProvider.previewData.container)

        let viewModel = try! SleepViewModel(
            appCoordinator: mockCoordinator,
            sleepDataManager: mockManager
        )

        viewModel.currentCycle = PreviewSleepDataProvider.completedSleepCycle
        viewModel.historyCycles = PreviewSleepDataProvider.sampleSleepCycles

        return viewModel
    }

    // MARK: - New Cycle (manual entry)
    static var newCycleViewModel: SleepViewModel {
        let viewModel = makePreviewViewModel()
        viewModel.entryMode = .manual
        viewModel.showManualEntry = true
        viewModel.isEditingLastCycle = false

        let now = Date()
        viewModel.manualEndDate = now
        viewModel.manualStartDate = now.addingTimeInterval(-8 * 3600)
        viewModel.selectedQuality = 5

        return viewModel
    }

    // MARK: - Edit Cycle (completed)
    static var editCycleViewModel: SleepViewModel {
        let viewModel = makePreviewViewModel()
        viewModel.entryMode = .manual
        viewModel.showManualEntry = true
        viewModel.isEditingLastCycle = true

        let cycle = PreviewSleepDataProvider.completedSleepCycle
        viewModel.currentCycle = cycle
        viewModel.manualStartDate = cycle.dateStart
        viewModel.manualEndDate = cycle.dateEnding ?? Date()
        viewModel.selectedQuality = cycle.quality

        return viewModel
    }

    // MARK: - Active Cycle (currently running)
    static var activeCycleViewModel: SleepViewModel {
        let viewModel = makePreviewViewModel()
        viewModel.currentCycle = PreviewSleepDataProvider.activeSleepCycle
        viewModel.entryMode = .toggle
        viewModel.showManualEntry = false
        viewModel.isEditingLastCycle = false
        return viewModel
    }

    // MARK: - Active + History (1 active + 7 completed)
    static var activeAndHistoryViewModel: SleepViewModel {
        let viewModel = makePreviewViewModel()

        viewModel.currentCycle = PreviewSleepDataProvider.activeSleepCycle
        viewModel.historyCycles = PreviewSleepDataProvider.sampleSleepCycles

        viewModel.entryMode = .toggle
        viewModel.showManualEntry = false
        viewModel.isEditingLastCycle = false
        viewModel.selectedQuality = 0

        return viewModel
    }

    // MARK: - Sample Data

    /// 7 completed sleep cycles (from newest to oldest)
    static var sampleSleepCycles: [SleepCycleDisplay] {
        let now = Date()
        var displays: [SleepCycleDisplay] = []

        for index in 0..<7 {
            let date = now.addingTimeInterval(Double(-index) * 86400)
            let start = calendar.date(bySettingHour: 22, minute: 30, second: 0, of: date)!
            let end = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: date)!
                .addingTimeInterval(86400)
            let quality = Int16(Int.random(in: 1...10))

            let display = SleepCycleDisplay(
                id: UUID(),
                dateStart: start,
                dateEnding: end,
                quality: quality
            )
            displays.append(display)
        }

        return displays
    }

    /// Active sleep cycle (still ongoing)
    static var activeSleepCycle: SleepCycleDisplay {
        let start = calendar.date(bySettingHour: 22, minute: 30, second: 0, of: Date())!
        return SleepCycleDisplay(
            id: UUID(),
            dateStart: start,
            dateEnding: nil,
            quality: 0
        )
    }

    /// Completed full night (22:30 → 6:45)
    static var completedSleepCycle: SleepCycleDisplay {
        let now = Date()
        let start = calendar.date(bySettingHour: 22, minute: 30, second: 0, of: now)!
        let end = calendar.date(bySettingHour: 6, minute: 45, second: 0, of: now)!
            .addingTimeInterval(86400)
        return SleepCycleDisplay(
            id: UUID(),
            dateStart: start,
            dateEnding: end,
            quality: 8
        )
    }

    /// Short nap (14:00 → 15:30)
    static var napCycle: SleepCycleDisplay {
        let now = Date()
        let start = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let end = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: now)!
        return SleepCycleDisplay(
            id: UUID(),
            dateStart: start,
            dateEnding: end,
            quality: 6
        )
    }

    /// Bad quality night (23:00 → 5:30)
    static var badQualityCycle: SleepCycleDisplay {
        let yesterday = Date().addingTimeInterval(-86400)
        let start = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: yesterday)!
        let end = calendar.date(bySettingHour: 5, minute: 30, second: 0, of: yesterday)!
            .addingTimeInterval(86400)
        return SleepCycleDisplay(
            id: UUID(),
            dateStart: start,
            dateEnding: end,
            quality: 2
        )
    }
}

//
//  SleepViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 26/09/2025.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class SleepViewModelTests: XCTestCase {
    
    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var sleepDataManager: SleepDataManager!
    var coordinator: AppCoordinator!
    var spyToastyManager: SpyToastyManager!
    var sut: SleepViewModel!
    
    override func setUp() {
        super.setUp()
        
        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        sleepDataManager = SleepDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: UserDataManager(container: testContainer.container))
        spyToastyManager = ToastyTestHelpers.createSpyManager()
        
        try! context.save()
        
        sut = try! SleepViewModel(appCoordinator: coordinator, sleepDataManager: sleepDataManager)
        sut.configureToasty(toastyManager: spyToastyManager)
    }
    
    override func tearDown() {
        sut = nil
        spyToastyManager = nil
        coordinator = nil
        sleepDataManager = nil
        testContainer = nil
        super.tearDown()
    }
    
    /// Initialization Tests
    
    func test_init_withLoggedUser_setsUpCorrectly() throws {
        // Then
        XCTAssertNotNil(sut.currentUser)
        XCTAssertEqual(sut.currentState, .none)
        XCTAssertNil(sut.currentCycle)
        XCTAssertFalse(sut.showEditModal)
    }
    
    /// Current State Tests
    
    func test_isActive_returnsExpectedValues() {
        // Given
        let activeCycle = SleepCycleDisplay(id: UUID(), dateStart: Date(), dateEnding: nil, quality: 6)
        let completedCycle = SleepCycleDisplay(id: UUID(), dateStart: Date(), dateEnding: Date(), quality: 8)

        // When
        let activeState = SleepTrackingState.active(activeCycle)
        let completedState = SleepTrackingState.completed(completedCycle)
        let noneState = SleepTrackingState.none

        // Then
        XCTAssertTrue(activeState.isActive)
        XCTAssertFalse(completedState.isActive)
        XCTAssertFalse(noneState.isActive)
    }

    func test_currentState_withNoLastCycle_returnsNone() throws {
        // Given / When / Then
        XCTAssertEqual(sut.currentState, .none)
    }
    
    func test_currentState_withActiveCycle_returnsActive() throws {
        // Given
        let startDate = Date()
        let cycle = try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate).toDisplay
        sut.currentCycle = cycle
        
        // When
        let state = sut.currentState
        
        // Then
        if case .active(let activeCycle) = state {
            XCTAssertEqual(activeCycle.dateStart, startDate)
            XCTAssertNil(activeCycle.dateEnding)
        } else {
            XCTFail("Expected .active state")
        }
    }
    
    func test_currentState_withCompletedCycle_returnsCompleted() throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(8 * 3600)
        let cycle = try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate).toDisplay
        try sleepDataManager.endSleepCycle(for: sut.currentUser, endDate: endDate, quality: 8)
        sut.currentCycle = cycle
        
        // When
        sut.reloadAllData()
        let state = sut.currentState
        
        // Then
        if case .completed(let completedCycle) = state {
            XCTAssertEqual(completedCycle.dateStart, startDate)
            XCTAssertEqual(completedCycle.dateEnding, endDate)
            XCTAssertEqual(completedCycle.quality, 8)
        } else {
            XCTFail("Expected .completed state")
        }
    }
    
    /// Start Sleep Cycle Tests
    
    func test_startSleepCycle_success_updatesStateAndLastCycle() throws {
        // Given
        let startDate = Date()
        XCTAssertEqual(sut.currentState, .none)
        
        // When
        sut.startSleepCycle(startDate: startDate)
        
        // Then
        XCTAssertNotNil(sut.currentCycle)
        XCTAssertEqual(sut.currentCycle?.dateStart, startDate)
        XCTAssertNil(sut.currentCycle?.dateEnding)
        
        if case .active = sut.currentState {
            // Success
        } else {
            XCTFail("Expected .active state after starting cycle")
        }
        
        XCTAssertEqual(spyToastyManager.showCallCount, 0)
    }
    
    /// End Sleep Cycle Tests
    
    func test_endSleepCycle_success_updatesStateAndLastCycle() throws {
        // Given
        sut.configureToasty(toastyManager: spyToastyManager)

        let startDate = Date()
        sut.startSleepCycle(startDate: startDate)

        guard case .active = sut.currentState else {
            XCTFail("Expected .active state"); return
        }

        sut.selectedQuality = 7
        let endDate = startDate.addingTimeInterval(8 * 3600)

        // When
        sut.endSleepCycle(endDate: endDate)

        // Then
        XCTAssertNotNil(sut.currentCycle?.dateEnding)
        XCTAssertEqual(sut.currentCycle?.dateEnding, endDate)
        XCTAssertEqual(sut.currentCycle?.quality, 7)

        if case .completed = sut.currentState {
        } else {
            XCTFail("Expected .completed state after ending cycle")
        }

        XCTAssertEqual(spyToastyManager.showCallCount, 0)
    }

    
    func test_endSleepCycle_withNoActiveSession_showsError() throws {
        // Given
        XCTAssertEqual(sut.currentState, .none)
        
        // When
        sut.endSleepCycle()
        
        // Then
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
    }
    
    func test_endSleepCycle_withInvalidDates_showsError() throws {
        // Given
        let startDate = Date()
        try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        
        let endDate = startDate.addingTimeInterval(-3600) // 1 hour before
        
        // When
        sut.endSleepCycle(endDate: endDate)
        
        // Then
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
    }
    
    /// ToastyManager Configuration Tests
    
    func test_configure_setsToastyManager() throws {
        // When
        sut.configureToasty(toastyManager: spyToastyManager)
        
        // Then
        XCTAssertNotNil(sut.toastyManager)
        XCTAssertTrue(sut.toastyManager === spyToastyManager)
    }

    /// History Cycles Tests

    func test_historyCycles_withNoCycles_returnsEmptyArray() throws {
        // Given - No cycle created
        
        // When
        let cycles = sut.historyCycles
        
        // Then
        XCTAssertTrue(cycles.isEmpty)
    }

    func test_historyCycles_withMultipleCycles_returnsLimitedSortedCycles() throws {
        // Given
        for i in 0..<10 {
            let date = Date().addingTimeInterval(Double(-i) * 86400)
            try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: date)
            try sleepDataManager.endSleepCycle(for: sut.currentUser)
        }
        
        // When
        sut.reloadAllData()
        let cycles = sut.historyCycles
        
        // Then
        if cycles.count >= 2 {
            XCTAssertTrue(cycles[0].dateStart > cycles[1].dateStart)
        }
    }

    func test_historyCycles_withFewerThan7Cycles_returnsAllCycles() throws {
        // Given
        for i in 0..<3 {
            let date = Date().addingTimeInterval(Double(-i) * 86400)
            try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: date)
            try sleepDataManager.endSleepCycle(for: sut.currentUser)
        }
        
        // When
        sut.reloadAllData()
        let cycles = sut.historyCycles
        
        // Then
        XCTAssertEqual(cycles.count, 2)
    }

    func test_historyCycles_doesNotContainLastCycle() throws {
        // Given
        for i in 0..<5 {
            let date = Date().addingTimeInterval(Double(-i) * 86400)
            try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: date)
            try sleepDataManager.endSleepCycle(for: sut.currentUser)
        }
        
        // When
        sut.reloadAllData()
        
        // Then
        XCTAssertNotNil(sut.currentCycle)
        XCTAssertFalse(sut.historyCycles.isEmpty)
        
        if let lastCycle = sut.currentCycle, let firstHistory = sut.historyCycles.first {
            XCTAssertNotEqual(lastCycle.id, firstHistory.id)
        }
    }

    /// Delete Cycle Tests

    func test_deleteHistoryCycle_removesCycle() throws {
        // Given
        let startDate = Date()
        _ = try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        _ = try sleepDataManager.endSleepCycle(for: sut.currentUser,
                                               endDate: startDate.addingTimeInterval(8 * 3600),
                                               quality: 6)
        sut.reloadAllData()

        guard let cycle = sut.currentCycle else {
               XCTFail("Expected currentCycle to exist")
               return
           }
    
        // When
        sut.deleteHistoryCycle(cycle)

        // Then
        XCTAssertTrue(
            try sleepDataManager.fetchSleepCycles(for: sut.currentUser).isEmpty,
            "Cycle should be deleted from Core Data"
        )
    }

    /// Cancel Edit Tests

    func test_cancelEdit_hidesModalAndClearsEditingCycle() throws {
        // Given
        let cycle = SleepCycleDisplay(
            id: UUID(),
            dateStart: Date().addingTimeInterval(-8 * 3600),
            dateEnding: Date(),
            quality: 6
        )

        sut.openEditModal(for: cycle)
        XCTAssertTrue(sut.showEditModal)
        XCTAssertNotNil(sut.editingCycle)

        // When
        sut.cancelEdit()

        // Then
        XCTAssertFalse(sut.showEditModal)
        XCTAssertNil(sut.editingCycle)
    }

    /// Save Cycle Tests

    func test_saveCycle_createsNewCycle() throws {
        // Given
        sut.manualStartDate = Date().addingTimeInterval(-8 * 3600)
        sut.manualEndDate = Date()
        sut.selectedQuality = 7
        sut.editingCycle = nil

        // When
        sut.saveCycle()

        // Then
        XCTAssertNotNil(sut.currentCycle)
        XCTAssertEqual(sut.currentCycle?.quality, 7)
        XCTAssertFalse(sut.showEditModal)
    }

    func test_saveCycle_updatesExistingCycle() throws {
        // Given
        let startDate = Date().addingTimeInterval(-8 * 3600)
        let endDate = Date()
        try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        try sleepDataManager.endSleepCycle(for: sut.currentUser,
                                           endDate: endDate,
                                           quality: 5)
        sut.reloadAllData()

        sut.openEditModal(for: sut.currentCycle)
        sut.manualStartDate = startDate.addingTimeInterval(-3600)
        sut.manualEndDate = endDate.addingTimeInterval(3600)
        sut.selectedQuality = 9

        // When
        sut.saveCycle()

        // Then
        XCTAssertEqual(sut.currentCycle?.quality, 9)
        XCTAssertFalse(sut.showEditModal)
    }

    /// Start Sleep Cycle Error Tests

    func test_startSleepCycle_whenAlreadyActive_showsError() throws {
        // Given
        sut.startSleepCycle()
        XCTAssertNotNil(sut.currentCycle)

        // When
        sut.startSleepCycle()

        // Then
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
    }

    func test_openEditModal_withoutCycle_createsDefaultCycle() throws {
        // When
        sut.openEditModal(for: nil)
        
        // Then
        XCTAssertTrue(sut.showEditModal)
        XCTAssertNotNil(sut.editingCycle)

        guard let cycle = sut.editingCycle else {
            XCTFail("Expected a default editing cycle"); return
        }

        let now = Date()
        let expectedStart = now.addingTimeInterval(-8 * 3600)
        
        // Dates should be close to now / now - 8h
        XCTAssertLessThan(abs(cycle.dateStart.timeIntervalSince(expectedStart)), 5)
        XCTAssertLessThan(abs(cycle.dateEnding!.timeIntervalSince(now)), 5)

        // Default quality should be 5
        XCTAssertEqual(cycle.quality, 5)
    }
}

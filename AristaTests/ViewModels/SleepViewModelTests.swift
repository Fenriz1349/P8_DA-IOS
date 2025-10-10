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
        
        // Créer et connecter un utilisateur
        let user = SharedTestHelper.createSampleUser(in: context)
        try! context.save()
        try! coordinator.login(id: user.id)
        
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
    
    // MARK: - Initialization Tests
    
    func test_init_withLoggedUser_setsUpCorrectly() throws {
        // Then
        XCTAssertNotNil(sut.currentUser)
        XCTAssertEqual(sut.currentState, .none)
        XCTAssertNil(sut.lastCycle)
        XCTAssertEqual(sut.entryMode, .toggle)
        XCTAssertFalse(sut.showManualEntry)
        XCTAssertFalse(sut.isEditingLastCycle)
    }
    
    func test_init_withNoLoggedUser_throwsError() throws {
        // Given
        coordinator.currentUser = nil
        
        // When / Then
        XCTAssertThrowsError(try SleepViewModel(appCoordinator: coordinator, sleepDataManager: sleepDataManager)) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }
    
    // MARK: - Current State Tests
    
    func test_currentState_withNoLastCycle_returnsNone() throws {
        // Given / When / Then
        XCTAssertEqual(sut.currentState, .none)
    }
    
    func test_currentState_withActiveCycle_returnsActive() throws {
        // Given
        let startDate = Date()
        let cycle = try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        sut.lastCycle = cycle
        
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
        let cycle = try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        try sleepDataManager.endSleepCycle(for: sut.currentUser, endDate: endDate, quality: 8)
        sut.lastCycle = cycle
        
        // When
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
    
    // MARK: - Load Last Cycle Tests
    
    func test_loadLastCycle_withNoCycles_setsLastCycleToNil() throws {
        // Given / When
        sut.loadLastCycle()
        
        // Then
        XCTAssertNil(sut.lastCycle)
        XCTAssertEqual(sut.currentState, .none)
    }
    
    func test_loadLastCycle_withMultipleCycles_setsLastCycleToMostRecent() throws {
        // Given
        let date1 = Date().addingTimeInterval(-86400)
        let date2 = Date()
        
        try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: date1)
        try sleepDataManager.endSleepCycle(for: sut.currentUser)
        
        try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: date2)
        
        // When
        sut.loadLastCycle()
        
        // Then
        XCTAssertNotNil(sut.lastCycle)
        XCTAssertEqual(sut.lastCycle?.dateStart, date2)
    }
    
    // MARK: - Start Sleep Cycle Tests
    
    func test_startSleepCycleWithToggle_success_updatesStateAndLastCycle() throws {
        // Given
        let startDate = Date()
        XCTAssertEqual(sut.currentState, .none)
        
        // When
        sut.startSleepCycleWithToggle(startDate: startDate)
        
        // Then
        XCTAssertNotNil(sut.lastCycle)
        XCTAssertEqual(sut.lastCycle?.dateStart, startDate)
        XCTAssertNil(sut.lastCycle?.dateEnding)
        
        if case .active = sut.currentState {
            // Success
        } else {
            XCTFail("Expected .active state after starting cycle")
        }
        
        XCTAssertEqual(spyToastyManager.showCallCount, 0) // Pas d'erreur
    }
    
    func test_startSleepCycleWithToggle_withActiveSession_showsError() throws {
        // Given - Créer un cycle actif
        try sleepDataManager.startSleepCycle(for: sut.currentUser)
        sut.loadLastCycle()
        
        // When
        sut.startSleepCycleWithToggle()
        
        // Then
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
        XCTAssertNotNil(spyToastyManager.lastMessage)
    }
    
    // MARK: - End Sleep Cycle Tests
    
    func test_endSleepCycleWithToggle_success_updatesStateAndLastCycle() throws {
        // Given - Démarrer un cycle
        let startDate = Date()
        try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        sut.loadLastCycle()
        sut.selectedQuality = 7
        
        guard case .active = sut.currentState else { XCTFail("Expected .active state"); return }
        
        let endDate = startDate.addingTimeInterval(8 * 3600)
        
        // When
        sut.endSleepCycleWithToggle(endDate: endDate)
        
        // Then
        XCTAssertNotNil(sut.lastCycle?.dateEnding)
        XCTAssertEqual(sut.lastCycle?.dateEnding, endDate)
        XCTAssertEqual(sut.lastCycle?.quality, 7)
        
        if case .completed = sut.currentState {
            // Success
        } else {
            XCTFail("Expected .completed state after ending cycle")
        }
        
        XCTAssertEqual(spyToastyManager.showCallCount, 0) // Pas d'erreur
    }
    
    func test_endSleepCycleWithToggle_withNoActiveSession_showsError() throws {
        // Given - Pas de cycle actif
        XCTAssertEqual(sut.currentState, .none)
        
        // When
        sut.endSleepCycleWithToggle()
        
        // Then
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
    }
    
    func test_endSleepCycleWithToggle_withInvalidDates_showsError() throws {
        // Given
        let startDate = Date()
        try sleepDataManager.startSleepCycle(for: sut.currentUser, startDate: startDate)
        sut.loadLastCycle()
        
        let endDate = startDate.addingTimeInterval(-3600) // 1 heure avant
        
        // When
        sut.endSleepCycleWithToggle(endDate: endDate)
        
        // Then
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
    }
    
    // MARK: - Manual Entry Tests
    
    func test_saveManualEntry_withValidDates_success() throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(8 * 3600)
        sut.manualStartDate = startDate
        sut.manualEndDate = endDate
        sut.selectedQuality = 6
        
        // When
        sut.saveManualEntry()
        
        // Then
        XCTAssertNotNil(sut.lastCycle)
        XCTAssertEqual(sut.lastCycle?.dateStart, startDate)
        XCTAssertEqual(sut.lastCycle?.dateEnding, endDate)
        XCTAssertEqual(sut.lastCycle?.quality, 6)
        XCTAssertFalse(sut.showManualEntry) // Should close modal
        XCTAssertEqual(spyToastyManager.showCallCount, 0)
    }
    
    func test_saveManualEntry_withInvalidDates_showsError() throws {
        // Given
        sut.showManualEntryMode()
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-3600)
        sut.manualStartDate = startDate
        sut.manualEndDate = endDate
        
        // When
        sut.saveManualEntry()
        
        // Then
        XCTAssertNil(sut.lastCycle)
        XCTAssertTrue(sut.showManualEntry)
        XCTAssertEqual(spyToastyManager.showCallCount, 1)
        XCTAssertEqual(spyToastyManager.lastType, .error)
    }
    
    // MARK: - Edit Last Cycle Tests
    
    func test_editLastCycle_withCompletedCycle_entersEditMode() throws {
        // Given
        let cycle = try sleepDataManager.startSleepCycle(for: sut.currentUser)
        try sleepDataManager.endSleepCycle(for: sut.currentUser, quality: 5)
        sut.lastCycle = cycle
        
        // When
        sut.editLastCycle()
        
        // Then
        XCTAssertTrue(sut.isEditingLastCycle)
        XCTAssertEqual(sut.manualStartDate, cycle.dateStart)
        XCTAssertEqual(sut.manualEndDate, cycle.dateEnding)
    }
    
    func test_saveEditedCycle_success_updatesLastCycle() throws {
        // Given
        let cycle = try sleepDataManager.startSleepCycle(for: sut.currentUser)
        try sleepDataManager.endSleepCycle(for: sut.currentUser)
        sut.lastCycle = cycle
        sut.isEditingLastCycle = true
        sut.selectedQuality = 9
        
        let newStartDate = Date().addingTimeInterval(-3600)
        let newEndDate = Date()
        sut.manualStartDate = newStartDate
        sut.manualEndDate = newEndDate
        
        // When
        sut.saveEditedCycle()
        
        // Then
        XCTAssertEqual(sut.lastCycle?.dateStart, newStartDate)
        XCTAssertEqual(sut.lastCycle?.dateEnding, newEndDate)
        XCTAssertEqual(sut.lastCycle?.quality, 9)
        XCTAssertFalse(sut.isEditingLastCycle) // Exit edit mode
        XCTAssertEqual(spyToastyManager.showCallCount, 0)
    }
    
    // MARK: - ToastyManager Configuration Tests
    
    func test_configure_setsToastyManager() throws {
        // When
        sut.configureToasty(toastyManager: spyToastyManager)
        
        // Then
        XCTAssertNotNil(sut.toastyManager)
        XCTAssertTrue(sut.toastyManager === spyToastyManager)
    }
    
    // MARK: - Entry Mode Tests
    
    func test_showManualEntryMode_setsCorrectState() throws {
        // Given
        XCTAssertEqual(sut.entryMode, .toggle)
        XCTAssertFalse(sut.showManualEntry)
        
        // When
        sut.showManualEntryMode()
        
        // Then
        XCTAssertEqual(sut.entryMode, .manual)
        XCTAssertTrue(sut.showManualEntry)
    }
    
    func test_cancelManualEntry_resetsState() throws {
        // Given
        sut.entryMode = .manual
        sut.showManualEntry = true
        sut.isEditingLastCycle = true
        
        // When
        sut.cancelManualEntry()
        
        // Then
        XCTAssertEqual(sut.entryMode, .toggle)
        XCTAssertFalse(sut.showManualEntry)
        XCTAssertFalse(sut.isEditingLastCycle)
    }

    // MARK: - History Cycles Tests

    func test_historyCycles_withNoCycles_returnsEmptyArray() throws {
        // Given - Aucun cycle créé
        
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
        let cycles = sut.historyCycles
        
        // Then
        XCTAssertEqual(cycles.count, 7)
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
        let cycles = sut.historyCycles
        
        // Then
        XCTAssertEqual(cycles.count, 3)
    }
}

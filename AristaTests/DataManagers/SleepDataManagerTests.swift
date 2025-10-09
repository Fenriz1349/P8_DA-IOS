//
//  SleepDataManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 25/09/2025.
//

import XCTest
import CoreData
@testable import Arista

final class SleepDataManagerTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: SleepDataManager!
    var testUser: User!
    
    override func setUp() {
        super.setUp()
        persistenceController = SharedTestHelper.createTestContainer()
        context = persistenceController.container.viewContext
        manager = SleepDataManager(container: persistenceController.container)
        
        testUser = SharedTestHelper.createSampleUser(in: context)
        try! context.save()
    }
    
    override func tearDown() {
        testUser = nil
        manager = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Start Sleep Cycle Tests
    
    func test_startSleepCycle_withValidUser_shouldCreateSleepCycle() throws {
        // Given
        let startDate = Date()
        
        // When
        let sleepCycle = try manager.startSleepCycle(for: testUser, startDate: startDate)
        
        // Then
        XCTAssertNotNil(sleepCycle)
        XCTAssertEqual(sleepCycle.dateStart, startDate)
        XCTAssertNil(sleepCycle.dateEnding)
        XCTAssertEqual(sleepCycle.quality, 0)
        XCTAssertEqual(sleepCycle.user.id, testUser.id)
    }

    func test_startSleepCycle_withActiveSession_shouldThrowActiveSessionExists() throws {
        // Given
        try manager.startSleepCycle(for: testUser)
        
        // When / Then
        XCTAssertThrowsError(try manager.startSleepCycle(for: testUser)) { error in
            XCTAssertEqual(error as? SleepDataManagerError, .activeSessionAlreadyExists)
        }
    }
    
    // MARK: - End Sleep Cycle Tests
    
    func test_endSleepCycle_withActiveCycle_shouldUpdateCycle() throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(8 * 3600)
        let quality: Int16 = 8
        
        try manager.startSleepCycle(for: testUser, startDate: startDate)
        
        // When
        let completedCycle = try manager.endSleepCycle(for: testUser, endDate: endDate, quality: quality)
        
        // Then
        XCTAssertNotNil(completedCycle.dateEnding)
        XCTAssertEqual(completedCycle.dateEnding, endDate)
        XCTAssertEqual(completedCycle.quality, quality)
        XCTAssertEqual(completedCycle.dateStart, startDate)
    }
    
    func test_endSleepCycle_withoutActiveCycle_shouldThrowSleepCycleNotFound() throws {
        // Given - no active Cycle
        
        // When / Then
        XCTAssertThrowsError(try manager.endSleepCycle(for: testUser)) { error in
            XCTAssertEqual(error as? SleepDataManagerError, .sleepCycleNotFound)
        }
    }

    func test_endSleepCycle_withoutQuality_shouldKeepDefaultQuality() throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(8 * 3600)
        
        try manager.startSleepCycle(for: testUser, startDate: startDate)
        
        // When
        let completedCycle = try manager.endSleepCycle(for: testUser, endDate: endDate)
        
        // Then
        XCTAssertEqual(completedCycle.quality, 0)
    }
    
    // MARK: - Active Sleep Cycle Tests
    
    func test_hasActiveSleepCycle_withActiveCycle_shouldReturnTrue() throws {
        // Given
        try manager.startSleepCycle(for: testUser)
        
        // When
        let hasActive = try manager.hasActiveSleepCycle(for: testUser)
        
        // Then
        XCTAssertTrue(hasActive)
    }
    
    func test_hasActiveSleepCycle_withoutActiveCycle_shouldReturnFalse() throws {
        // Given - Aucun cycle
        
        // When
        let hasActive = try manager.hasActiveSleepCycle(for: testUser)
        
        // Then
        XCTAssertFalse(hasActive)
    }
    
    func test_hasActiveSleepCycle_withCompletedCycle_shouldReturnFalse() throws {
        // Given
        try manager.startSleepCycle(for: testUser)
        try manager.endSleepCycle(for: testUser)
        
        // When
        let hasActive = try manager.hasActiveSleepCycle(for: testUser)
        
        // Then
        XCTAssertFalse(hasActive)
    }
    
    func test_getActiveSleepCycle_withActiveCycle_shouldReturnCycle() throws {
        // Given
        let startDate = Date()
        try manager.startSleepCycle(for: testUser, startDate: startDate)
        
        // When
        let activeCycle = try manager.getActiveSleepCycle(for: testUser)
        
        // Then
        XCTAssertNotNil(activeCycle)
        XCTAssertEqual(activeCycle?.dateStart, startDate)
        XCTAssertNil(activeCycle?.dateEnding)
    }
    
    func test_getActiveSleepCycle_withoutActiveCycle_shouldReturnNil() throws {
        // Given - No avtive cycle
        
        // When
        let activeCycle = try manager.getActiveSleepCycle(for: testUser)
        
        // Then
        XCTAssertNil(activeCycle)
    }
    
    // MARK: - Fetch Sleep Cycles Tests
    
    func test_fetchSleepCycles_withMultipleCycles_shouldReturnSortedCycles() throws {
        // Given
        let date1 = Date().addingTimeInterval(-86400 * 2)
        let date2 = Date().addingTimeInterval(-86400)
        let date3 = Date()
        
        try manager.startSleepCycle(for: testUser, startDate: date1)
        try manager.endSleepCycle(for: testUser, endDate: date1.addingTimeInterval(8 * 3600))
        
        try manager.startSleepCycle(for: testUser, startDate: date2)
        try manager.endSleepCycle(for: testUser, endDate: date2.addingTimeInterval(7 * 3600))
        
        try manager.startSleepCycle(for: testUser, startDate: date3)
        
        // When
        let cycles = try manager.fetchSleepCycles(for: testUser)
        
        // Then
        XCTAssertEqual(cycles.count, 3)
        // Vérifier l'ordre (plus récent en premier)
        XCTAssertEqual(cycles[0].dateStart, date3)
        XCTAssertEqual(cycles[1].dateStart, date2)
        XCTAssertEqual(cycles[2].dateStart, date1)
    }
    
    // MARK: - Delete Sleep Cycle Tests
    
    func test_deleteSleepCycle_shouldRemoveCycleFromStore() throws {
        // Given
        let sleepCycle = try manager.startSleepCycle(for: testUser)
        XCTAssertEqual(try manager.fetchSleepCycles(for: testUser).count, 1)
        
        // When
        try manager.deleteSleepCycle(sleepCycle)
        
        // Then
        XCTAssertEqual(try manager.fetchSleepCycles(for: testUser).count, 0)
    }
    
    // MARK: - Update Sleep Quality Tests
    
    func test_updateSleepQuality_withCompletedCycle_shouldUpdateQuality() throws {
        // Given
        let sleepCycle = try manager.startSleepCycle(for: testUser)
        try manager.endSleepCycle(for: testUser, quality: 5)
        let newQuality: Int16 = 8
        
        // When
        try manager.updateSleepQuality(for: sleepCycle, quality: newQuality)
        
        // Then
        XCTAssertEqual(sleepCycle.quality, newQuality)
    }
    
    func test_updateSleepQuality_withActiveCycle_shouldThrowError() throws {
        // Given
        let sleepCycle = try manager.startSleepCycle(for: testUser)
        
        // When / Then
        XCTAssertThrowsError(try manager.updateSleepQuality(for: sleepCycle, quality: 8)) { error in
            XCTAssertEqual(error as? SleepDataManagerError, .sleepCycleNotFound)
        }
    }
}

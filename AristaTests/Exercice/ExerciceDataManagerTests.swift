//
//  ExerciceDataManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 22/10/2025.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciceDataManagerTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: ExerciceDataManager!
    var testUser: User!

    override func setUp() {
        super.setUp()
        persistenceController = SharedTestHelper.createTestContainer()
        context = persistenceController.container.viewContext
        manager = ExerciceDataManager(container: persistenceController.container)

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

    /// Create
    func test_createExercice_shouldCreateAndSave() throws {
        // Given / When
        let exercice = try manager.createExercice(for: testUser,
                                                  date: Date(),
                                                  duration: 45,
                                                  type: .running,
                                                  intensity: 7)

        // Then
        XCTAssertEqual(exercice.type, ExerciceType.running.rawValue)
        XCTAssertEqual(exercice.duration, 45)
        XCTAssertEqual(exercice.intensity, 7)
        XCTAssertEqual(exercice.user.id, testUser.id)
    }
    
    func test_createExercice_withInvalidData_throwsInvalidDataError() {
        // Given / When / Then
        XCTAssertThrowsError(
            try manager.createExercice(for: testUser,
                                       date: Date(),
                                       duration: -10,
                                       type: .running,
                                       intensity: 7)
        ) { error in
            XCTAssertEqual(error as? ExerciceDataManagerError, .invalidData)
        }
    }
    
    /// Fetch
    func test_fetchExercices_returnsAllForUser() throws {
        // Given
        SharedTestHelper.createSampleExercice(for: testUser, in: context)
        SharedTestHelper.createSampleExercice(for: testUser, in: context)
        try context.save()
        
        // When
        let results = try manager.fetchExercices(for: testUser)
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    func test_fetchLastWeekExercices_returnsOnlyRecentOnes() throws {
        // Given
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        try manager.createExercice(for: testUser, date: oldDate)
        try manager.createExercice(for: testUser, date: Date())
        
        // When
        let recent = try manager.fetchLastWeekExercices(for: testUser)
        
        // Then
        XCTAssertEqual(recent.count, 1)
    }
    
    /// Update
    func test_updateExercice_shouldModifyExisting() throws {
        // Given
        let exercice = try manager.createExercice(for: testUser,
                                                  duration: 40,
                                                  type: .cycling,
                                                  intensity: 6)
        let newDate = Date().addingTimeInterval(-3600)
        
        // When
        try manager.updateExercice(by: exercice.id,
                                   date: newDate,
                                   type: .yoga,
                                   duration: 55,
                                   intensity: 9)
        
        // Then
        let fetched = try manager.fetchExercices(for: testUser)
        let updated = fetched.first(where: { $0.id == exercice.id })
        
        XCTAssertNotNil(updated)
        XCTAssertEqual(updated?.type, ExerciceType.yoga.rawValue)
        XCTAssertEqual(updated?.duration, 55)
        XCTAssertEqual(updated?.intensity, 9)
    }
    
    func test_updateExercice_withInvalidData_throwsError() throws {
        // Given
        let exercice = try manager.createExercice(for: testUser)
        
        // When / Then
        XCTAssertThrowsError(
            try manager.updateExercice(by: exercice.id,
                                       date: Date(),
                                       type: .running,
                                       duration: -1,
                                       intensity: 8)
        ) { error in
            XCTAssertEqual(error as? ExerciceDataManagerError, .invalidData)
        }
    }
    
    func test_updateExercice_withInvalidId_throwsNotFoundError() throws {
        // Given / When / Then
        XCTAssertThrowsError(
            try manager.updateExercice(by: UUID(),
                                       date: Date(),
                                       type: .yoga,
                                       duration: 30,
                                       intensity: 5)
        ) { error in
            XCTAssertEqual(error as? ExerciceDataManagerError, .exerciceNotFound)
        }
    }
    
    /// Delete
    func test_deleteExercice_shouldRemoveFromStore() throws {
        // Given
        let exercice = try manager.createExercice(for: testUser)
        XCTAssertEqual(try manager.fetchExercices(for: testUser).count, 1)
        
        // When
        try manager.deleteExercice(exercice)
        
        // Then
        XCTAssertEqual(try manager.fetchExercices(for: testUser).count, 0)
    }
}

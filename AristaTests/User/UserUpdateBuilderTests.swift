//
//  UserUpdateBuilderTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 29/08/2025.
//

import XCTest
import CoreData
@testable import Arista

final class UserUpdateBuilderTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: UserDataManager!

    override func setUp() {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        manager = UserDataManager(container: persistenceController.container)
    }

    func test_updateNamesAndGoals_success() throws {
        // Given
        let user = manager.getOrCreateUser()
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // When
        try builder.firstName("Selina")
            .lastName("Kyle")
            .calorieGoal(1500)
            .sleepGoal(420)
            .waterGoal(20)
            .stepsGoal(10000)
            .save()
        
        // Then
        XCTAssertEqual(user.firstName, "Selina")
        XCTAssertEqual(user.lastName, "Kyle")
        XCTAssertEqual(user.calorieGoal, 1500)
        XCTAssertEqual(user.sleepGoal, 420)
        XCTAssertEqual(user.waterGoal, 20)
        XCTAssertEqual(user.stepsGoal, 10000)
    }

    func test_updateGoals_withNegativeValues_throws() {
        // Given
        let user = manager.getOrCreateUser()
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(try builder.calorieGoal(-1).save())
        XCTAssertThrowsError(try builder.sleepGoal(-1).save())
        XCTAssertThrowsError(try builder.waterGoal(-1).save())
        XCTAssertThrowsError(try builder.stepsGoal(-1).save())
    }

    func test_updateNames_withEmptyValues_throws() {
        // Given
        let user = manager.getOrCreateUser()
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(try builder.firstName("").save())
        XCTAssertThrowsError(try builder.lastName("").save())
    }
}


//
//  UserTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 28/08/2025.
//

import XCTest
import CoreData
@testable import Arista

final class UserTests: XCTestCase {
    var controller: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: UserDataManager!

    override func setUp() {
        controller = SharedTestHelper.createTestContainer()
        context = controller.container.viewContext
        manager = UserDataManager(container: controller.container)
    }

    func test_user_hasDefaultGoals() {
        // When
        let user = manager.getOrCreateUser()
        
        // Then
        XCTAssertEqual(user.calorieGoal, 300)
        XCTAssertEqual(user.sleepGoal, 480)
        XCTAssertEqual(user.waterGoal, 25)
        XCTAssertEqual(user.stepsGoal, 8000)
    }

    func test_user_relations() throws {
        // Given
        let user = manager.getOrCreateUser()
        SharedTestHelper.createSampleExercice(for: user, in: context)
        SharedTestHelper.createSampleSleepCycle(for: user, in: context)
        SharedTestHelper.makeGoal(for: user, in: context, date: Date())
        try context.save()
        
        // Then
        XCTAssertEqual(user.exercices?.count, 1)
        XCTAssertEqual(user.sleepCycles?.count, 1)
        XCTAssertEqual(user.goals?.count, 1)
    }

    func test_toDisplay_matchesUserProperties() {
        // Given
        let user = manager.getOrCreateUser()
        
        // When
        let display = user.toDisplay()
        
        // Then
        XCTAssertEqual(display.firstName, user.firstName)
        XCTAssertEqual(display.lastName, user.lastName)
        XCTAssertEqual(display.calorieGoal, Int(user.calorieGoal))
        XCTAssertEqual(display.sleepGoal, Int(user.sleepGoal))
        XCTAssertEqual(display.waterGoal, Int(user.waterGoal))
        XCTAssertEqual(display.stepsGoal, Int(user.stepsGoal))
    }

    func test_userDisplay_formatters() {
        // Given
        let display = UserDisplay(id: UUID(), firstName: "Jane", lastName: "Smith",
                                  calorieGoal: 2000, sleepGoal: 450, waterGoal: 30, stepsGoal: 12000)
        
        // Then
        XCTAssertEqual(display.fullName, "Jane Smith")
        XCTAssertEqual(display.calorieGoalFormatted, "2000 kcal")
        XCTAssertEqual(display.sleepGoalFormatted, "7h30")
        XCTAssertEqual(display.waterGoalFormatted, "3.0 L")
        XCTAssertTrue(display.stepsGoalFormatted.contains("12"))
    }
}


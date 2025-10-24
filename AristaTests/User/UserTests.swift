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

    override func setUpWithError() throws {
        controller = SharedTestHelper.createTestContainer()
        context = controller.container.viewContext
    }

    override func tearDownWithError() throws {
        controller = nil
        context = nil
    }

    func test_createUser_shouldPersistAndRetrieve() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)

        // When
        try SharedTestHelper.saveContext(context)

        // Then
        let request: NSFetchRequest<User> = User.fetchRequest()
        let results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.email, SharedTestHelper.sampleUserData.email)
        XCTAssertTrue(results.first?.hashPassword.isEmpty == false)
    }

    func test_userGoals_haveDefaultValues() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)

        // Then
        XCTAssertEqual(user.calorieGoal, 300)
        XCTAssertEqual(user.sleepGoal, 480)
        XCTAssertEqual(user.waterGoal, 25)
        XCTAssertEqual(user.stepsGoal, 8000)
    }

    func test_user_canLinkExercicesAndSleepCyclesAndGoals() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let exercice = SharedTestHelper.createSampleExercice(for: user, in: context)
        let sleepCycle = SharedTestHelper.createSampleSleepCycle(for: user, in: context)
        let goal = SharedTestHelper.makeGoal(for: user, in: context, date: Date())

        // When
        try SharedTestHelper.saveContext(context)

        // Then
        XCTAssertEqual(user.exercices?.count, 1)
        XCTAssertEqual(user.sleepCycles?.count, 1)
        XCTAssertEqual(user.goals?.count, 1)
        XCTAssertTrue(user.exercices?.contains(exercice) ?? false)
        XCTAssertTrue(user.sleepCycles?.contains(sleepCycle) ?? false)
        XCTAssertTrue(user.goals?.contains(goal) ?? false)
    }
}


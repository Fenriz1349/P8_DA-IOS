//
//  GoalDataManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
import CoreData
@testable import Arista

final class GoalDataManagerTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: GoalDataManager!
    var testUser: User!

    override func setUp() {
        super.setUp()
        persistenceController = SharedTestHelper.createTestContainer()
        context = persistenceController.container.viewContext
        manager = GoalDataManager(container: persistenceController.container)
        testUser = UserDataManager(container: persistenceController.container).getOrCreateUser()
        try! context.save()
    }

    override func tearDown() {
        testUser = nil
        manager = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    /// Water Tests

    func test_updateWater_shouldCreateNewGoal() throws {
        /// Given
        let today = Date()

        /// When
        let goal = try manager.updateWater(for: testUser, date: today, newWater: 25)

        /// Then
        XCTAssertEqual(goal.totalWater, 25)
        XCTAssertEqual(goal.totalSteps, 0)
        XCTAssertEqual(goal.user.id, testUser.id)
        XCTAssertEqual(goal.date.formattedDate, today.formattedDate)
    }

    func test_updateWater_shouldUpdateExistingGoal() throws {
        /// Given
        let today = Date()
        _ = try manager.updateWater(for: testUser, date: today, newWater: 20)

        /// When
        let updated = try manager.updateWater(for: testUser, date: today, newWater: 15)

        /// Then
        XCTAssertEqual(updated.totalWater, 15)
        let all = try manager.fetchGoals(for: testUser)
        XCTAssertEqual(all.count, 1)
    }

    /// Steps Tests

    func test_updateSteps_shouldCreateNewGoal() throws {
        /// Given
        let today = Date()

        /// When
        let goal = try manager.updateSteps(for: testUser, date: today, newSteps: 5000)

        /// Then
        XCTAssertEqual(goal.totalSteps, 5000)
        XCTAssertEqual(goal.totalWater, 0)
        XCTAssertEqual(goal.user.id, testUser.id)
        XCTAssertEqual(goal.date.formattedDate, today.formattedDate)
    }

    func test_updateSteps_shouldUpdateExistingGoal() throws {
        /// Given
        let today = Date()
        _ = try manager.updateSteps(for: testUser, date: today, newSteps: 3000)

        /// When
        let updated = try manager.updateSteps(for: testUser, date: today, newSteps: 2000)

        /// Then
        XCTAssertEqual(updated.totalSteps, 2000)
        let all = try manager.fetchGoals(for: testUser)
        XCTAssertEqual(all.count, 1)
    }


    /// Integration Tests

    func test_updateWaterAndSteps_shouldUpdateSameGoal() throws {
        /// Given
        let today = Date()
        
        /// When
        let waterGoal = try manager.updateWater(for: testUser, date: today, newWater: 20)
        let stepsGoal = try manager.updateSteps(for: testUser, date: today, newSteps: 5000)
        
        /// Then
        XCTAssertEqual(waterGoal.id, stepsGoal.id)
        XCTAssertEqual(stepsGoal.totalWater, 20)
        XCTAssertEqual(stepsGoal.totalSteps, 5000)
        
        let all = try manager.fetchGoals(for: testUser)
        XCTAssertEqual(all.count, 1)
    }

    /// Fetch Tests

    func test_fetchGoals_shouldReturnAllUserGoals() throws {
        /// Given
        let referenceDate = Date()
        let today = referenceDate
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate)!
        
        _ = try manager.updateWater(for: testUser, date: today, newWater: 20)
        _ = try manager.updateWater(for: testUser, date: yesterday, newWater: 15)

        /// When
        let goals = try manager.fetchGoals(for: testUser)

        /// Then
        XCTAssertEqual(goals.count, 2)
        XCTAssertTrue(goals.contains { $0.totalWater == 20 })
        XCTAssertTrue(goals.contains { $0.totalWater == 15 })
    }

    func test_fetchLastWeekGoals_shouldReturnOnlyRecentGoals() throws {
        /// Given
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        _ = try manager.updateWater(for: testUser, date: oldDate, newWater: 10)
        _ = try manager.updateWater(for: testUser, newWater: 30)

        /// When
        let recentGoals = try manager.fetchLastWeekGoals(for: testUser)

        /// Then
        XCTAssertEqual(recentGoals.count, 1)
        XCTAssertEqual(recentGoals.first?.totalWater, 30)
    }

    func test_fetchGoal_shouldReturnGoalForGivenDate() throws {
        /// Given
        let today = Date()
        _ = try manager.updateWater(for: testUser, date: today, newWater: 22)

        /// When
        let fetched = try manager.fetchGoal(for: testUser, date: today)

        /// Then
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.totalWater, 22)
        XCTAssertEqual(fetched?.user.id, testUser.id)
    }

    func test_fetchGoal_withInvalidDate_shouldReturnNil() throws {
        /// Given
        let missingDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!

        /// When
        let fetched = try manager.fetchGoal(for: testUser, date: missingDate)

        /// Then
        XCTAssertNil(fetched)
    }

    /// Delete Tests

    func test_deleteGoal_shouldRemoveGoalFromStore() throws {
        /// Given
        let goal = try manager.updateWater(for: testUser, newWater: 25)
        XCTAssertEqual(try manager.fetchGoals(for: testUser).count, 1)

        /// When
        try manager.deleteGoal(goal)

        /// Then
        XCTAssertEqual(try manager.fetchGoals(for: testUser).count, 0)
    }
}

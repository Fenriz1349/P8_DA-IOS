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

    func test_upsertGoal_shouldCreateNewGoal() throws {
        /// Given
        let today = Date()

        /// When
        let goal = try manager.createOrUpdate(for: testUser, date: today, amount: 25)

        /// Then
        XCTAssertEqual(goal.totalWater, 25)
        XCTAssertEqual(goal.user.id, testUser.id)
        XCTAssertEqual(goal.date.formattedDate, today.formattedDate)
    }

    func test_upsertGoal_shouldUpdateExistingGoal() throws {
        /// Given
        let today = Date()
        _ = try manager.createOrUpdate(for: testUser, date: today, amount: 20)

        /// When
        let updated = try manager.createOrUpdate(for: testUser, date: today, amount: 35)

        /// Then
        XCTAssertEqual(updated.totalWater, 55)
        let all = try manager.fetchGoals(for: testUser)
        XCTAssertEqual(all.count, 1)
    }

    func test_fetchLastWeekGoals_shouldReturnOnlyRecentGoals() throws {
        /// Given
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        _ = try manager.createOrUpdate(for: testUser, date: oldDate, amount: 10)
        _ = try manager.createOrUpdate(for: testUser, amount: 30)

        /// When
        let recentGoals = try manager.fetchLastWeekGoals(for: testUser)

        /// Then
        XCTAssertEqual(recentGoals.count, 1)
        XCTAssertEqual(recentGoals.first?.totalWater, 30)
    }

    func test_fetchGoal_shouldReturnGoalForGivenDate() throws {
        /// Given
        let today = Date()
        _ = try manager.createOrUpdate(for: testUser, date: today, amount: 22)

        /// When
        let fetched = try manager.fetchGoal(for: testUser, date: today)

        /// Then
        XCTAssertEqual(fetched.totalWater, 22)
        XCTAssertEqual(fetched.user.id, testUser.id)
    }

    func test_fetchGoal_withInvalidDate_shouldThrowError() throws {
        /// Given
        let missingDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!

        /// When / Then
        XCTAssertThrowsError(try manager.fetchGoal(for: testUser, date: missingDate)) { error in
            XCTAssertEqual(error as? GoalDataManagerError, .goalNotFound)
        }
    }

    func test_deleteGoal_shouldRemoveGoalFromStore() throws {
        /// Given
        let goal = try manager.createOrUpdate(for: testUser, amount: 25)
        XCTAssertEqual(try manager.fetchGoals(for: testUser).count, 1)

        /// When
        try manager.deleteGoal(goal)

        /// Then
        XCTAssertEqual(try manager.fetchGoals(for: testUser).count, 0)
    }
}

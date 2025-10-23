//
//  GoalTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
import CoreData
@testable import Arista

final class GoalTests: XCTestCase {

    var controller: PersistenceController!
    var context: NSManagedObjectContext!
    var user: User!

    override func setUpWithError() throws {
        controller = SharedTestHelper.createTestContainer()
        context = controller.container.viewContext
        user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
    }

    override func tearDownWithError() throws {
        user = nil
        context = nil
        controller = nil
    }

    // MARK: - Tests

    func test_toDisplay_shouldMapBasicValues() throws {
        /// Given
        let goal = SharedTestHelper.makeGoal(for: user, in: context, date: Date(), water: 25)
        try context.save()

        /// When
        let display = goal.toDisplay()

        /// Then
        XCTAssertEqual(display.totalWater, 25)
        XCTAssertTrue(display.isToday)
        XCTAssertEqual(display.totalWater, 25)
    }

    func test_toDisplay_shouldIncludeUserExercisesAndSleepCycles() throws {
        /// Given
        let today = Date()
        let goal = SharedTestHelper.makeGoal(for: user, in: context, date: today, water: 15)

        _ = SharedTestHelper.createSampleExercice(for: user, in: context,
                                                  date: today, duration: 60, type: .running, intensity: 5)

        _ = SharedTestHelper.createSampleSleepCycle(for: user, in: context,
                                                    startOffset: -8 * 3600, duration: 8 * 3600, quality: 7)
        try context.save()

        /// When
        let display = goal.toDisplay()

        /// Then
        XCTAssertEqual(display.exercices.count, 1)
        XCTAssertEqual(display.sleepCycles.count, 1)
        XCTAssertEqual(display.totalCalories, 450)
        XCTAssertEqual(display.totalSleepMinutes, 480)
    }

    func test_mapToDisplay_shouldMapMultipleGoals() throws {
        /// Given
        let goals = SharedTestHelper.makeWeekGoals(for: user, in: context)
        try context.save()

        /// When
        let displays = Goal.mapToDisplay(from: goals)

        /// Then
        XCTAssertEqual(displays.count, 7)
        XCTAssertTrue(displays.contains { $0.totalWater == 20 })
        XCTAssertTrue(displays.contains { $0.totalWater == 26 })
    }

    func test_totalSleepMinutes_shouldIgnoreIncompleteCycles() throws {
        /// Given
        let goal = SharedTestHelper.makeGoal(for: user, in: context, date: Date())

        let cycle = SleepCycle(context: context)
        cycle.id = UUID()
        cycle.dateStart = Date()
        cycle.dateEnding = nil
        cycle.quality = 8
        cycle.user = user

        try context.save()

        /// When
        let display = goal.toDisplay()

        /// Then
        XCTAssertEqual(display.totalSleepMinutes, 0)
    }

    func test_totalCalories_shouldIgnoreExercisesFromOtherDays() throws {
        // Given
        let today = Date()
        let goal = SharedTestHelper.makeGoal(for: user, in: context, date: today)

        let oldDate = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        _ = SharedTestHelper.createSampleExercice(for: user, in: context,
                                                  date: oldDate, duration: 60, intensity: 10)
        try context.save()

        // When
        let display = goal.toDisplay()

        // Then
        XCTAssertEqual(display.totalCalories, 0)
    }
}


//
//  SleepCycleTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
import CoreData
@testable import Arista

final class SleepCycleTests: XCTestCase {

    var controller: PersistenceController!
    var context: NSManagedObjectContext!
    var user: User!

    override func setUpWithError() throws {
        controller = SharedTestHelper.createTestContainer()
        context = controller.container.viewContext
        user = UserDataManager(container: controller.container).getOrCreateUser()
    }

    override func tearDownWithError() throws {
        controller = nil
        context = nil
        user = nil
    }

    func test_toDisplay_shouldReturnMatchingDisplayValues() throws {
        // Given
        let start = Date()
        let end = start.addingTimeInterval(8 * 3600)
        let cycle = SleepCycle(context: context)
        cycle.id = UUID()
        cycle.dateStart = start
        cycle.dateEnding = end
        cycle.quality = 7
        cycle.user = user

        // When
        let display = cycle.toDisplay

        // Then
        XCTAssertEqual(display.id, cycle.id)
        XCTAssertEqual(display.dateStart, cycle.dateStart)
        XCTAssertEqual(display.dateEnding, cycle.dateEnding)
        XCTAssertEqual(display.quality, Int(cycle.quality))
    }

    func test_mapToDisplay_shouldConvertAllCycles() throws {
        // Given
        let cycles = [
            SharedTestHelper.createSampleSleepCycle(for: user, in: context, quality: 5),
            SharedTestHelper.createSampleSleepCycle(for: user, in: context, quality: 9)
        ]

        // When
        let displays = SleepCycle.mapToDisplay(from: cycles)

        // Then
        XCTAssertEqual(displays.count, 2)
        XCTAssertEqual(displays.first?.quality, 5)
        XCTAssertEqual(displays.last?.quality, 9)
    }

    func test_isCompleted_shouldBeTrueWhenDateEndingExists() {
        // Given
        let display = SleepCycleDisplay(
            id: UUID(),
            dateStart: Date(),
            dateEnding: Date(),
            quality: 6
        )

        // Then
        XCTAssertTrue(display.isCompleted)
        XCTAssertFalse(display.isActive)
    }

    func test_isActive_shouldBeTrueWhenNoDateEnding() {
        // Given
        let display = SleepCycleDisplay(
            id: UUID(),
            dateStart: Date(),
            dateEnding: nil,
            quality: 7
        )

        // Then
        XCTAssertTrue(display.isActive)
        XCTAssertFalse(display.isCompleted)
    }

    func test_sleepQuality_andDescription_shouldMatchGrade() {
        // Given
        let display = SleepCycleDisplay(
            id: UUID(),
            dateStart: Date(),
            dateEnding: Date(),
            quality: 9
        )

        // When
        let grade = display.sleepQuality

        // Then
        XCTAssertEqual(grade.value, 9)
        XCTAssertEqual(display.qualityDescription, "grade.excellent".localized)
    }
}

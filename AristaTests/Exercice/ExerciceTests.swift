//
//  ExerciceTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciceTests: XCTestCase {

    var controller: PersistenceController!
    var context: NSManagedObjectContext!
    var user: User!

    override func setUpWithError() throws {
        controller = SharedTestHelper.createTestContainer()
        context = controller.container.viewContext
        user = SharedTestHelper.createSampleUser(in: context)
    }

    override func tearDownWithError() throws {
        controller = nil
        context = nil
        user = nil
    }

    func test_toDisplay_shouldReturnMatchingDisplayValues() throws {
        // Given
        let exercice = Exercice(context: context)
        exercice.id = UUID()
        exercice.date = Date()
        exercice.duration = 60
        exercice.intensity = 7
        exercice.type = ExerciceType.running.rawValue
        exercice.user = user

        // When
        let display = exercice.toDisplay

        // Then
        XCTAssertEqual(display.id, exercice.id)
        XCTAssertEqual(display.date, exercice.date)
        XCTAssertEqual(display.duration, Int(exercice.duration))
        XCTAssertEqual(display.intensity, Int(exercice.intensity))
        XCTAssertEqual(display.type, .running)
    }

    func test_mapToDisplay_shouldConvertAllExercises() throws {
        // Given
        let ex1 = SharedTestHelper.createSampleExercice(for: user, in: context)
        let ex2 = SharedTestHelper.createSampleExercice(for: user, in: context)

        // When
        let displays = Exercice.mapToDisplay(from: [ex1, ex2])

        // Then
        XCTAssertEqual(displays.count, 2)
        XCTAssertEqual(displays.first?.duration, Int(ex1.duration))
    }

    func test_intensityDescription_shouldMatchGrade() {
        // Given
        let display = ExerciceDisplay(
            id: UUID(),
            date: Date(),
            duration: 45,
            intensity: 9,
            type: .running
        )

        // Then
        XCTAssertEqual(display.exerciceIntensity.value, 9)
        XCTAssertEqual(display.intensityDescription, "grade.excellent".localized)
    }

    func test_caloriesBurned_shouldScaleWithTypeAndIntensity() {
        // Given
        let running = ExerciceDisplay(
            id: UUID(),
            date: Date(),
            duration: 60,
            intensity: 10,
            type: .running
        )
        let yoga = ExerciceDisplay(
            id: UUID(),
            date: Date(),
            duration: 60,
            intensity: 10,
            type: .yoga
        )

        // When
        let runningCalories = running.caloriesBurned
        let yogaCalories = yoga.caloriesBurned

        // Then
        XCTAssertTrue(runningCalories > yogaCalories)
        XCTAssertEqual(runningCalories, Int(60 * 10 * 1.5))
    }

    func test_typeEnum_getterSetter_shouldConvertProperly() {
        // Given
        let exercice = Exercice(context: context)
        exercice.type = ExerciceType.tennis.rawValue

        // When
        XCTAssertEqual(exercice.typeEnum, .tennis)

        // And
        exercice.typeEnum = .cycling

        // Then
        XCTAssertEqual(exercice.type, ExerciceType.cycling.rawValue)
    }

    func test_exerciceType_shouldHaveValidDisplayNamesAndIcons() {
        // Given
        let typesToCheck: [ExerciceType] = [.running, .boxing, .yoga, .volleyball, .other]

        // Then
        for type in typesToCheck {
            XCTAssertFalse(type.displayName.isEmpty, "Display name should not be empty for \(type)")
            XCTAssertFalse(type.iconName.isEmpty, "Icon name should not be empty for \(type)")
            XCTAssertGreaterThan(type.calorieFactor, 0, "Calorie factor should be > 0 for \(type)")
        }
    }

    func test_calorieFactor_shouldBeHigherForIntenseSports() {
        // Given
        let running = ExerciceType.running
        let yoga = ExerciceType.yoga
        let boxing = ExerciceType.boxing

        // Then
        XCTAssertTrue(running.calorieFactor > yoga.calorieFactor)
        XCTAssertTrue(boxing.calorieFactor > yoga.calorieFactor)
    }
}

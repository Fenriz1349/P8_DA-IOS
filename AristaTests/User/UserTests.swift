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
        SharedTestHelper.createSampleUser(in: context)

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
    
    // MARK: - toDisplay Tests
    
    func test_toDisplay_shouldConvertToUserDisplay() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        
        // When
        let display = user.toDisplay()
        
        // Then
        XCTAssertEqual(display.id, user.id)
        XCTAssertEqual(display.firstName, user.firstName)
        XCTAssertEqual(display.lastName, user.lastName)
        XCTAssertEqual(display.email, user.email)
        XCTAssertEqual(display.calorieGoal, Int(user.calorieGoal))
        XCTAssertEqual(display.sleepGoal, Int(user.sleepGoal))
        XCTAssertEqual(display.waterGoal, Int(user.waterGoal))
        XCTAssertEqual(display.stepsGoal, Int(user.stepsGoal))
    }
    
    func test_toDisplay_shouldPreserveAllGoalValues() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        user.calorieGoal = 2500
        user.sleepGoal = 420
        user.waterGoal = 30
        user.stepsGoal = 12000
        
        // When
        let display = user.toDisplay()
        
        // Then
        XCTAssertEqual(display.calorieGoal, 2500)
        XCTAssertEqual(display.sleepGoal, 420)
        XCTAssertEqual(display.waterGoal, 30)
        XCTAssertEqual(display.stepsGoal, 12000)
    }
    
    // MARK: - User Properties Tests
    
    func test_user_shouldStoreAllProperties() throws {
        // Given
        let user = User(context: context)
        user.id = UUID()
        user.email = "test@example.com"
        user.firstName = "John"
        user.lastName = "Doe"
        user.hashPassword = "hashedpassword123"
        user.salt = UUID()
        user.isLogged = true
        user.calorieGoal = 2000
        user.sleepGoal = 480
        user.waterGoal = 25
        user.stepsGoal = 10000
        
        // When
        try context.save()
        
        // Then
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.hashPassword, "hashedpassword123")
        XCTAssertTrue(user.isLogged)
        XCTAssertNotNil(user.salt)
    }
    
    func test_user_relationships_shouldBeOptional() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        
        // Then
        XCTAssertNotNil(user.exercices)
        XCTAssertNotNil(user.sleepCycles)
        XCTAssertNotNil(user.goals)
    }
    
    // MARK: - UserDisplay Tests
    
    func test_userDisplay_fullName_shouldCombineFirstAndLastName() {
        // Given
        let display = UserDisplay(
            id: UUID(),
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        
        // When
        let fullName = display.fullName
        
        // Then
        XCTAssertEqual(fullName, "Jane Smith")
    }
    
    func test_userDisplay_calorieGoalFormatted_shouldAppendKcal() {
        // Given
        let display = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2500,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        
        // When
        let formatted = display.calorieGoalFormatted
        
        // Then
        XCTAssertEqual(formatted, "2500 kcal")
    }
    
    func test_userDisplay_sleepGoalFormatted_withWholeHours_shouldReturnHoursOnly() {
        // Given
        let display = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480, // 8 hours
            waterGoal: 25,
            stepsGoal: 10000
        )
        
        // When
        let formatted = display.sleepGoalFormatted
        
        // Then
        XCTAssertEqual(formatted, "8h")
    }
    
    func test_userDisplay_sleepGoalFormatted_withHoursAndMinutes_shouldReturnBoth() {
        // Given
        let display = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 450, // 7h30
            waterGoal: 25,
            stepsGoal: 10000
        )
        
        // When
        let formatted = display.sleepGoalFormatted
        
        // Then
        XCTAssertEqual(formatted, "7h30")
    }
    
    func test_userDisplay_waterGoalFormatted_shouldReturnLiters() {
        // Given
        let display = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 30, // 3.0 L
            stepsGoal: 10000
        )
        
        // When
        let formatted = display.waterGoalFormatted
        
        // Then
        XCTAssertEqual(formatted, "3.0 L")
    }
    
    func test_userDisplay_stepsGoalFormatted_shouldUseFormatSteps() {
        // Given
        let display = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 12000
        )
        
        // When
        let formatted = display.stepsGoalFormatted
        
        // Then
        // Should use formatSteps extension (locale-dependent formatting)
        XCTAssertTrue(formatted.contains("12"))
        XCTAssertTrue(formatted.contains("000"))
    }
    
    func test_userDisplay_equatable_shouldCompareCorrectly() {
        // Given
        let id = UUID()
        let display1 = UserDisplay(
            id: id,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        let display2 = UserDisplay(
            id: id,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        
        // Then
        XCTAssertEqual(display1, display2)
    }
    
    func test_userDisplay_equatable_shouldDetectDifferences() {
        // Given
        let display1 = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        let display2 = UserDisplay(
            id: UUID(),
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com",
            calorieGoal: 2500,
            sleepGoal: 420,
            waterGoal: 30,
            stepsGoal: 12000
        )
        
        // Then
        XCTAssertNotEqual(display1, display2)
    }
    
    func test_userDisplay_identifiable_shouldHaveUniqueIDs() {
        // Given
        let display1 = UserDisplay(
            id: UUID(),
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        let display2 = UserDisplay(
            id: UUID(),
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com",
            calorieGoal: 2000,
            sleepGoal: 480,
            waterGoal: 25,
            stepsGoal: 10000
        )
        
        // Then
        XCTAssertNotEqual(display1.id, display2.id)
    }
    
    // MARK: - FetchRequest Test
    
    func test_fetchRequest_shouldReturnCorrectEntityName() {
        // When
        let request = User.fetchRequest()
        
        // Then
        XCTAssertEqual(request.entityName, "User")
    }
}

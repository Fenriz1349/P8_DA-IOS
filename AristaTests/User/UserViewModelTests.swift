//
//  UserViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 12/09/2025.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class UserViewModelTests: XCTestCase {
    var container: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: UserDataManager!
    var goalManager: GoalDataManager!
    var coordinator: AppCoordinator!

    override func setUp() {
        container = SharedTestHelper.createTestContainer()
        context = container.container.viewContext
        dataManager = UserDataManager(container: container.container)
        goalManager = GoalDataManager(container: container.container)
        coordinator = AppCoordinator(dataManager: dataManager)
    }

    func test_init_loadsDemoUser() throws {
        // When
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalManager)
        
        // Then
        XCTAssertEqual(sut.user.firstName, "Bruce")
        XCTAssertEqual(sut.user.lastName, "Wayne")
    }

    func test_editUser_updatesValues() throws {
        // Given
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalManager)
        
        // When
        sut.firstName = "Alex"
        sut.lastName = "Dupont"
        sut.calorieGoal = 2500
        sut.saveChanges()
        
        // Then
        XCTAssertEqual(sut.user.firstName, "Alex")
        XCTAssertEqual(sut.user.lastName, "Dupont")
        XCTAssertEqual(sut.user.calorieGoal, 2500)
    }

    func test_invalidData_showsError() throws {
        // Given
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalManager)
        let toast = ToastyManager()
        sut.configureToasty(toastyManager: toast)
        
        // When
        sut.firstName = ""
        sut.saveChanges()
        
        // Then
        XCTAssertNotNil(sut.toastyManager)
    }

    func test_goalUpdates_syncWithGoalManager() async throws {
        // Given
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalManager)
        
        // When
        sut.currentWater = 15
        sut.currentSteps = 6000
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        let goal = try goalManager.fetchGoal(for: sut.user)
        XCTAssertEqual(goal?.totalWater, 15)
        XCTAssertEqual(goal?.totalSteps, 6000)
    }
}


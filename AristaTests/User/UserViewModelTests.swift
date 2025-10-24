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
    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: UserDataManager!
    var goalDataManager: GoalDataManager!
    var coordinator: AppCoordinator!

    override func setUp() {
        super.setUp()
        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        dataManager = UserDataManager(container: testContainer.container)
        goalDataManager = GoalDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: dataManager)
    }

    override func tearDown() {
        testContainer = nil
        context = nil
        dataManager = nil
        goalDataManager = nil
        coordinator = nil
        super.tearDown()
    }

    func test_init_withLoggedUser_loadsUserDataCorrectly() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)

        // When
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // Then
        XCTAssertEqual(sut.user.firstName, user.firstName)
        XCTAssertEqual(sut.user.lastName, user.lastName)
        XCTAssertFalse(sut.showEditModal)
    }

    func test_init_withNoLoggedUser_throwsError() throws {
        XCTAssertThrowsError(try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }

    func test_openAndCloseEditModal_shouldToggleShowEditModal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // When
        sut.openEditModal()
        XCTAssertTrue(sut.showEditModal)

        // Then
        sut.closeEditModal()
        XCTAssertFalse(sut.showEditModal)
    }

    func test_logout_shouldClearCurrentUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        XCTAssertTrue(coordinator.isAuthenticated)

        // When
        sut.logout()

        // Then
        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertNil(coordinator.currentUser)
    }

    func test_deleteAccount_shouldRemoveUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        XCTAssertTrue(coordinator.isAuthenticated)

        // When
        sut.deleteAccount()

        // Then
        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertNil(coordinator.currentUser)
    }

    func test_loadUser_shouldUpdatePublishedProperties() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // When
        sut.loadUser()

        // Then
        XCTAssertEqual(sut.firstName, user.firstName)
        XCTAssertEqual(sut.lastName, user.lastName)
    }

    func test_saveChanges_shouldUpdateUserData() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        sut.firstName = "Alex"
        sut.lastName = "Dupont"

        // When
        sut.saveChanges()

        // Then
        XCTAssertEqual(user.firstName, "Alex")
        XCTAssertEqual(user.lastName, "Dupont")
        XCTAssertFalse(sut.showEditModal)
    }

    func test_saveChanges_withInvalidData_shouldShowError() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        sut.firstName = ""
        sut.lastName = ""

        let fakeToasty = ToastyManager()
        sut.configureToasty(toastyManager: fakeToasty)

        // When
        sut.saveChanges()

        // Then
        XCTAssertNotNil(sut.toastyManager)
    }
    
    // MARK: - Goal Tests
    
    func test_loadTodayGoal_shouldLoadExistingGoal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        _ = try goalDataManager.updateWater(for: user, newWater: 15)
        _ = try goalDataManager.updateSteps(for: user, newSteps: 5000)
        
        // When
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // Then
        XCTAssertEqual(sut.currentWater, 15)
        XCTAssertEqual(sut.currentSteps, 5000)
    }
    
    func test_updateWater_shouldSaveToGoalDataManager() async throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        sut.currentWater = 20
        
        // Give time for Task to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        let goal = try goalDataManager.fetchGoal(for: user)
        XCTAssertEqual(goal?.totalWater, 20)
    }
    
    func test_updateSteps_shouldSaveToGoalDataManager() async throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        sut.currentSteps = 8000
        
        // Give time for Task to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        let goal = try goalDataManager.fetchGoal(for: user)
        XCTAssertEqual(goal?.totalSteps, 8000)
    }
}

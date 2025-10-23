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
    var coordinator: AppCoordinator!

    override func setUp() {
        super.setUp()
        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        dataManager = UserDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: dataManager)
    }

    override func tearDown() {
        testContainer = nil
        context = nil
        coordinator = nil
        super.tearDown()
    }

    func test_init_withLoggedUser_loadsUserDataCorrectly() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)

        // When
        let sut = try UserViewModel(appCoordinator: coordinator)

        // Then
        XCTAssertEqual(sut.user.firstName, user.firstName)
        XCTAssertEqual(sut.user.lastName, user.lastName)
        XCTAssertEqual(sut.user.email, user.email)
        XCTAssertFalse(sut.showEditModal)
    }

    func test_init_withNoLoggedUser_throwsError() throws {
        XCTAssertThrowsError(try UserViewModel(appCoordinator: coordinator)) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }

    func test_openAndCloseEditModal_shouldToggleShowEditModal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator)

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
        let sut = try UserViewModel(appCoordinator: coordinator)

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
        let sut = try UserViewModel(appCoordinator: coordinator)

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
        let sut = try UserViewModel(appCoordinator: coordinator)

        // When
        sut.loadUser()

        // Then
        XCTAssertEqual(sut.firstName, user.firstName)
        XCTAssertEqual(sut.lastName, user.lastName)
        XCTAssertEqual(sut.email, user.email)
    }

    func test_saveChanges_shouldUpdateUserData() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator)
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
        let sut = try UserViewModel(appCoordinator: coordinator)

        sut.firstName = ""
        sut.lastName = ""

        let fakeToasty = ToastyManager()
        sut.configureToasty(toastyManager: fakeToasty)

        // When
        sut.saveChanges()

        // Then
        XCTAssertNotNil(sut.toastyManager)
    }
}

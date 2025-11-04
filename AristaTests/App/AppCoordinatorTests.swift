//
//  AppCoordinatorTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 11/09/2025.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class AppCoordinatorTests: XCTestCase {

    var persistenceController: PersistenceController!
    var manager: UserDataManager!
    var coordinator: AppCoordinator!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistenceController = SharedTestHelper.createTestContainer()
        manager = UserDataManager(container: persistenceController.container)
        coordinator = AppCoordinator(dataManager: manager)
        context = manager.viewContext
    }

    override func tearDown() {
        coordinator = nil
        manager = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_init_createsDemoUserIfNoneExists() {
        // When
        let user = coordinator.currentUser

        // Then
        XCTAssertNotNil(user)
        XCTAssertEqual(user.firstName, "Bruce")
        XCTAssertEqual(user.lastName, "Wayne")

        // Verify uniqueness
        let request: NSFetchRequest<User> = User.fetchRequest()
        let users = try? context.fetch(request)
        XCTAssertEqual(users?.count, 1)
    }

    func test_makeUserViewModel_returnsViewModelWithCurrentUser() throws {
        // When
        let viewModel = try coordinator.makeUserViewModel()

        // Then
        XCTAssertEqual(viewModel.user.id, coordinator.currentUser.id)
    }

    func test_makeSleepViewModel_returnsValidViewModel() throws {
        // When
        let viewModel = try coordinator.makeSleepViewModel()

        // Then
        XCTAssertNotNil(viewModel)
    }

    func test_makeExerciseViewModel_returnsViewModelWithCurrentUser() throws {
        // When
        let viewModel = try coordinator.makeExerciceViewModel()

        // Then
        XCTAssertEqual(viewModel.currentUser.id, coordinator.currentUser.id)
    }
}

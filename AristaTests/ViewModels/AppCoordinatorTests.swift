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
        persistenceController = PersistenceController.createTestContainer()
        manager = UserDataManager(container: persistenceController.container)
        
        coordinator = AppCoordinator(dataManager: manager)
        coordinator.currentUser = nil
        context = manager.viewContext
    }
    
    override func tearDown() {
        coordinator.currentUser = nil
        coordinator = nil
        manager = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Auth state
    
    func test_setCurrentUser_updatesCurrentUser_and_isAuthenticatedTrue() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        
        // When
        try coordinator.login(id: user.id)
       
        // Then
        XCTAssertEqual(coordinator.currentUser?.id, user.id)
        XCTAssertTrue(coordinator.isAuthenticated)
        XCTAssertFalse(coordinator.dataManager.noUserLogged)
    }
    
    // MARK: - Logout
    
    func test_logout_setsCurrentUserNil_andLogsOffAllUsers() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        try builder.isLogged(true).save()
        XCTAssertTrue(user.isLogged)
        
        // When
        try coordinator.logout()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
        XCTAssertTrue(manager.noUserLogged)
    }
    
    // MARK: - Delete User
    
    func test_deleteCurrentUser_removesUserFromStore() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        try builder.isLogged(true).save()
        coordinator.currentUser = user
        
        XCTAssertNotNil(try? manager.fetchUser(by: user.id))
        
        // When
        try coordinator.deleteCurrentUser()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
    }
    
    func test_deleteCurrentUser_doesNothing_whenNoCurrentUser() throws {
        coordinator.currentUser = nil
        try coordinator.deleteCurrentUser()
        XCTAssertNil(coordinator.currentUser)
    }

    // MARK: - ViewModel creation tests

    func test_makeAccountViewModel_withLoggedUser_returnsViewModel() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let viewModel = try coordinator.makeAccountViewModel()
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.user.id, user.id)
    }

    func test_makeAccountViewModel_withNoLoggedUser_throwsError() throws {
        // Given / When / Then
        XCTAssertThrowsError(try coordinator.makeAccountViewModel()) { error in
            XCTAssertEqual(error as? AccountViewModelError, .noLoggedUser)
        }
    }

    func test_makeEditAccountViewModel_withLoggedUser_returnsViewModel() throws {
        //Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let viewModel = try coordinator.makeEditAccountViewModel()
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.firstName, user.firstName)
    }

    func test_makeEditAccountViewModel_withNoLoggedUser_throwsError() throws {
        // Given / When / Then
        XCTAssertThrowsError(try coordinator.makeEditAccountViewModel()) { error in
            XCTAssertEqual(error as? EditAccountViewModelError, .noLoggedUser)
        }
    }
    
    func test_init_withValidStoredSession_restoresCurrentUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        try builder.isLogged(true).save()
        UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
        
        // When
        let newCoordinator = AppCoordinator(dataManager: manager)
        
        // Then
        XCTAssertEqual(newCoordinator.currentUser?.id, user.id)
        XCTAssertTrue(newCoordinator.isAuthenticated)
    }

    func test_init_withStoredSessionButUserNotLogged_clearsSession() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
        
        // When
        let newCoordinator = AppCoordinator(dataManager: manager)
        
        // Then
        XCTAssertNil(newCoordinator.currentUser)
        XCTAssertNil(UserDefaults.standard.string(forKey: "currentUserId"))
    }

    func test_init_withInvalidStoredUserId_clearsSession() throws {
        // Given
        UserDefaults.standard.set("not-a-valid-uuid-format", forKey: "currentUserId")
        
        // When
        let newCoordinator = AppCoordinator(dataManager: manager)
        
        // Then
        XCTAssertNil(newCoordinator.currentUser)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "currentUserId"), "not-a-valid-uuid-format")
    }

    func test_init_withStoredSessionButUserNotFound_clearsSession() throws {
        // Given
        let nonExistentUserId = UUID()
        UserDefaults.standard.set(nonExistentUserId.uuidString, forKey: "currentUserId")
        
        // When
        let newCoordinator = AppCoordinator(dataManager: manager)
        
        // Then
        XCTAssertNil(newCoordinator.currentUser)
        XCTAssertNil(UserDefaults.standard.string(forKey: "currentUserId"))
    }

    func test_init_withNoStoredSession_startsWithoutUser() throws {
        // Given
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        
        // When
        let newCoordinator = AppCoordinator(dataManager: manager)
        
        // Then
        XCTAssertNil(newCoordinator.currentUser)
        XCTAssertFalse(newCoordinator.isAuthenticated)
    }
}

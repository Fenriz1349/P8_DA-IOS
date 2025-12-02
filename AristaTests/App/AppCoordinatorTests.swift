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
        
        coordinator = AppCoordinator(dataManager: manager, skipSessionRestore: true)
        coordinator.userDefaults = UserDefaults(suiteName: "com.arista.tests")!
        coordinator.currentUser = nil
        context = manager.viewContext
    }
    
    override func tearDown() {
        coordinator.currentUser = nil
        coordinator = nil
        manager = nil
        persistenceController = nil
        UserDefaults(suiteName: "com.arista.tests")?.removePersistentDomain(forName: "com.arista.tests")
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
    }

    func test_validateCurrentUser_withNoLoggedUser_throwsError() throws {
        // Given
        coordinator.currentUser = nil
        
        // When / Then
        XCTAssertThrowsError(try coordinator.validateCurrentUser()) {
            XCTAssertEqual($0 as? UserDataManagerError, .noLoggedUser)
        }
    }
    
    func test_validateCurrentUser_withLoggedUser_returnsUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let validatedUser = try coordinator.validateCurrentUser()
        
        // Then
        XCTAssertEqual(validatedUser.id, user.id)
    }

    // MARK: - Login resets previous users
    
    func test_login_unlogsAllOtherUsers() throws {
        // Given
        let user1 = SharedTestHelper.createSampleUser(in: context)
        let user2 = SharedTestHelper.createSampleUser(in: context)
        user1.isLogged = true
        try context.save()
        
        // When
        try coordinator.login(id: user2.id)
        
        // Then
        XCTAssertFalse(try manager.fetchUser(by: user1.id).isLogged)
        XCTAssertTrue(try manager.fetchUser(by: user2.id).isLogged)
    }

    // MARK: - Logout
    
    func test_logout_setsCurrentUserNil_andLogsOffCurrentUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        user.isLogged = true
        try context.save()
        coordinator.currentUser = user
        
        // When
        try coordinator.logout()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
        XCTAssertFalse(try manager.fetchUser(by: user.id).isLogged)
    }
    
    // MARK: - Delete User
    
    func test_deleteCurrentUser_removesUserFromStore() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        user.isLogged = true
        try context.save()
        coordinator.currentUser = user

        // When
        try coordinator.deleteCurrentUser()

        // Then
        XCTAssertNil(coordinator.currentUser)

        let remainingUsers = manager.fetchAllUsers()
        XCTAssertFalse(remainingUsers.contains(where: { $0.id == user.id }))
    }
    
    func test_deleteCurrentUser_doesNothing_whenNoCurrentUser() throws {
        // Given / When
        try coordinator.deleteCurrentUser()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
    }

    // MARK: - ViewModel creation tests

    func test_makeUserViewModel_withLoggedUser_returnsViewModel() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let viewModel = try coordinator.makeUserViewModel()
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.user.id, user.id)
        XCTAssertEqual(viewModel.user.firstName, user.firstName)
        XCTAssertEqual(viewModel.user.lastName, user.lastName)
    }

    func test_makeUserViewModel_withNoLoggedUser_throwsError() throws {
        XCTAssertThrowsError(try coordinator.makeUserViewModel()) {
            XCTAssertEqual($0 as? UserDataManagerError, .noLoggedUser)
        }
    }

    func test_makeAuthenticationViewModel_returnsViewModel() {
        // Given / When
        let viewModel = coordinator.makeAuthenticationViewModel
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertNil(coordinator.currentUser)
    }

    func test_makeAuthenticationViewModel_createsNewInstanceEachTime() {
        // Given / When
        let viewModel1 = coordinator.makeAuthenticationViewModel
        let viewModel2 = coordinator.makeAuthenticationViewModel
        
        // Then
        XCTAssertFalse(viewModel1 === viewModel2)
    }
    
    func test_makeSleepViewModel_withLoggedUser_returnsViewModel() throws {
        //Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let viewModel = try coordinator.makeSleepViewModel()
        
        // Then
        XCTAssertNotNil(viewModel)
    }

    func test_makeSleepViewModel_withNoLoggedUser_throwsError() throws {
        XCTAssertThrowsError(try coordinator.makeSleepViewModel()) {
            XCTAssertEqual($0 as? UserDataManagerError, .noLoggedUser)
        }
    }
    
    func test_makeExerciseViewModel_withLoggedUser_returnsViewModel() throws {
        //Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let viewModel = try coordinator.makeExerciceViewModel()
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.currentUser.id, user.id)
    }

    func test_makeExerciseViewModel_withNoLoggedUser_throwsError() throws {
        XCTAssertThrowsError(try coordinator.makeExerciceViewModel()) {
            XCTAssertEqual($0 as? UserDataManagerError, .noLoggedUser)
        }
    }
}

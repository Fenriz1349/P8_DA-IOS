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
    
    /// Auth state
    
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
        XCTAssertThrowsError(try coordinator.validateCurrentUser()) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
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

    /// Logout
    
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
    }
    
    /// Delete User
    
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

    /// ViewModel creation tests

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
        // Given / When / Then
        XCTAssertThrowsError(try coordinator.makeUserViewModel()) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }

    func test_makeAuthenticationViewModel_returnsViewModel() {
        // When
        let viewModel = coordinator.makeAuthenticationViewModel
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertNil(coordinator.currentUser)
    }

    func test_makeAuthenticationViewModel_createsNewInstanceEachTime() {
        // When
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
        // Given / When / Then
        XCTAssertThrowsError(try coordinator.makeSleepViewModel()) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
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
        // Given / When / Then
        XCTAssertThrowsError(try coordinator.makeExerciceViewModel()) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }
}

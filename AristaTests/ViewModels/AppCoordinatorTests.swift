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
}

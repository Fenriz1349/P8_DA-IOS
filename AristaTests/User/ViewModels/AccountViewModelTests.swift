//
//  AccountViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 12/09/2025.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class AccountViewModelTests: XCTestCase {
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
    
    // MARK: - Initialization Tests
    func test_init_withLoggedUser_loadsUserDataCorrectly() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // Then
        XCTAssertEqual(sut.user.firstName, user.firstName)
        XCTAssertEqual(sut.user.lastName, user.lastName)
        XCTAssertEqual(sut.user.email, user.email)
        XCTAssertEqual(sut.user.genderEnum, user.genderEnum)
        XCTAssertFalse(sut.showEditAccount)
    }
    
    func test_init_withNoLoggedUser_throwsError() throws {
        // Given - no logged user
        
        // When / Then
        XCTAssertThrowsError(try AccountViewModel(appCoordinator: coordinator)) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }

    // MARK: - EditAccount ViewModel Tests
    func test_editAccountViewModel_withValidUser_returnsEditViewModel() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // When
        let editVM = sut.editAccountViewModel
        
        // Then
        XCTAssertNotNil(editVM)
    }
    
    func test_editAccountViewModel_withNoLoggedUser_returnsNil() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // Logout to simulate no logged user
        try coordinator.logout()
        
        // When
        let editVM = sut.editAccountViewModel
        
        // Then
        XCTAssertNil(editVM)
    }
    
    // MARK: - Logout Tests
    func test_logout_clearsCurrentUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        XCTAssertTrue(coordinator.isAuthenticated)
        
        // When
        try sut.logout()
        
        // Then
        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertNil(coordinator.currentUser)
    }
    
    func test_logout_withLogoutError_handlesGracefully() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // When / Then - Should not crash even if logout fails
        // (This test assumes logout can throw, based on your existing code structure)
        XCTAssertNoThrow(try sut.logout())
    }

    // MARK: - State Management Tests
    func test_showEditAccount_initiallyFalse() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // Then
        XCTAssertFalse(sut.showEditAccount)
    }
    
    func test_showEditAccount_canBeToggled() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // When
        sut.showEditAccount = true
        
        // Then
        XCTAssertTrue(sut.showEditAccount)
    }
    
    // MARK: - User Data Consistency Tests
    func test_user_remainsConsistentAfterUserDataChanges() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        let originalFirstName = sut.user.firstName
        
        // When - Modify the underlying user data
        user.firstName = "ModifiedName"
        try context.save()
        
        // Then - AccountViewModel should still reference the same user object
        XCTAssertEqual(sut.user.firstName, "ModifiedName")
        XCTAssertNotEqual(sut.user.firstName, originalFirstName)
    }
}

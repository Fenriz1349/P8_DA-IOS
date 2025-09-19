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
        
        testContainer = PersistenceController.createTestContainer()
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
    
    func test_init_withLoggedUser_success() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // Then
        XCTAssertEqual(sut.user.id, user.id)
        XCTAssertFalse(sut.showEditAccount)
    }
    
    func test_init_withNoLoggedUser_throwsError() throws {
        // Given / When / Then
        XCTAssertThrowsError(try AccountViewModel(appCoordinator: coordinator)) { error in
            XCTAssertEqual(error as? AccountViewModelError, .noLoggedUser)
        }
    }
    
    func test_logout_resetsCurrentUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // When
        try sut.logout()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
    }
    
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
    
    func test_makeEditAccountViewModel_withLoggedUser_returnsViewModel() throws {
        //Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let sut = try AccountViewModel(appCoordinator: coordinator)
        
        // Then
        XCTAssertNotNil(sut.editAccountViewModel)
    }
}

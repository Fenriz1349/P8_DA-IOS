//
//  EditAccountViewModel.swift
//  AristaTests
//
//  Created by Julien Cotte on 16/09/2025.
//

import Foundation

import XCTest
import CoreData
@testable import Arista

@MainActor
final class EditAccountViewModelTests: XCTestCase {
    var sut: EditAccountViewModel!
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
        
        sut = EditAccountViewModel(appCoordinator: coordinator)
    }
    
    override func tearDown() {
        testContainer = nil
        context = nil
        coordinator = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - First Name, Updates are tested in UserUpdateBuiderTests
    func test_updateFirstName_success() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        try sut.updateFirstName("Alice")
        
        // Then
        XCTAssertEqual(coordinator.currentUser?.firstName, "Alice")
    }
    
    func test_updateFirstName_empty_throwError() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When // Then
        XCTAssertThrowsError(try sut.updateFirstName("")) { error in
            XCTAssertEqual(error as? UserUpdateBuilderError, .emptyFirstName)
        }
    }

    func test_deleteAccount_resetsCurrentUser() throws {
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        try sut.deleteAccount()
        
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        let users = try context.fetch(request)
        XCTAssertTrue(users.isEmpty)
    }
}

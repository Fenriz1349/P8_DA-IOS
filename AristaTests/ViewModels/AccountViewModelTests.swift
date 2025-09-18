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
    var sut: AccountViewModel!
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
        
        sut = AccountViewModel(appCoordinator: coordinator)
    }
    
    override func tearDown() {
        testContainer = nil
        context = nil
        coordinator = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Logout / Delete
    
    func test_logout_resetsCurrentUser() throws {
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        try sut.logout()
        
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
    }
}

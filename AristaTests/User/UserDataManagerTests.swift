//
//  UserDataManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 28/08/2025.
//

import CoreData
import XCTest
@testable import Arista

@MainActor
final class UserDataManagerTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: UserDataManager!

    override func setUp() {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        manager = UserDataManager(container: persistenceController.container)
    }

    func test_getOrCreateUser_createsDemoUserIfNoneExists() {
        // When
        let user = manager.getOrCreateDemoUser()
        // Then
        XCTAssertEqual(user.firstName, "Bruce")
        XCTAssertEqual(user.lastName, "Wayne")
    }

    func test_getOrCreateUser_returnsExistingUserIfAlreadyExists() {
        // Given
        _ = manager.getOrCreateDemoUser()
        // When
        let second = manager.getOrCreateDemoUser()
        // Then
        let request: NSFetchRequest<User> = User.fetchRequest()
        let users = try! context.fetch(request)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(second.firstName, "Bruce")
    }
    
    func test_loggedOffCurrentUser_unlogsOnlyTheLoggedUser() throws {
        // Given
        let user1 = SharedTestHelper.createSampleUser(in: context)
        let user2 = SharedTestHelper.createSampleUser(in: context)
        user1.isLogged = true
        try context.save()
        
        // When
        try manager.loggedOffCurrentUser()
        
        // Then
        XCTAssertFalse(try manager.fetchUser(by: user1.id).isLogged)
        XCTAssertFalse(try manager.fetchUser(by: user2.id).isLogged)
    }

}

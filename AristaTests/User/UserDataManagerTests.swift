//
//  UserDataManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 28/08/2025.
//

import CoreData
import XCTest
@testable import Arista

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
        let user = manager.getOrCreateUser()
        // Then
        XCTAssertEqual(user.firstName, "Bruce")
        XCTAssertEqual(user.lastName, "Wayne")
    }

    func test_getOrCreateUser_returnsExistingUserIfAlreadyExists() {
        // Given
        _ = manager.getOrCreateUser()
        // When
        let second = manager.getOrCreateUser()
        // Then
        let request: NSFetchRequest<User> = User.fetchRequest()
        let users = try! context.fetch(request)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(second.firstName, "Bruce")
    }
}

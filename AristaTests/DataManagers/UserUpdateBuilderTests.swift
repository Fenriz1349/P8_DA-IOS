//
//  UserUpdateBuilderTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import CoreData
import XCTest
@testable import Arista

final class UserUpdateBuilderTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: UserDataManager!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        manager = UserDataManager(container: persistenceController.container)
    }
    
    override func tearDown() {
        persistenceController = nil
        manager = nil
        super.tearDown()
    }
    
    func testUpdateFirstName_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.firstName("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyFirstName)
        }
    }

    func testUpdateFirstName() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // When
        try builder.firstName("Alice").save()
        
        // Then
        let updatedUser = try manager.fetchUser(by: user.id!)
        XCTAssertEqual(updatedUser.firstName, "Alice")
    }
    
    func testUpdateLastName_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.lastName("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyLastName)
        }
    }

    func testUpdateLastName() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)

        // When
        try builder.lastName("Batman").save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id!)
        XCTAssertEqual(updatedUser.lastName, "Batman")
    }
    
    func testUpdateEmail_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.email("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyEmail)
        }
    }

    func testUpdateEmail() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)

        // When
        try builder.email("Autremail@test.com").save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id!)
        XCTAssertEqual(updatedUser.email, "Autremail@test.com")
    }
}

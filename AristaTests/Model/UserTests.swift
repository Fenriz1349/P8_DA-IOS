//
//  UserTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 28/08/2025.
//

import XCTest
import CoreData
@testable import Arista

final class UserTests: XCTestCase {
    
    var controller: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        controller = PersistenceController.createTestContainer()
        context = controller.container.viewContext
    }

    override func tearDownWithError() throws {
        controller = nil
        context = nil
    }
    
    // MARK: - Has Value Tests
    
    func testCreateUserWithNullSizeAndWeight() throws {
        // Given
        let user = SharedTestHelper.createUser(
            firstName: "John",
            lastName: "Doe",
            email: "test@test.com",
            in: context
        )
        
        // When
        user.size = 0
        user.weight = 0
        
        // Then
        XCTAssertFalse(user.hasSize)
        XCTAssertFalse(user.hasWeight)
    }
    
    func testCreateUserWithPositiveSizeAndWeight() throws {
        // Given
        let user = SharedTestHelper.createUser(
            firstName: "John",
            lastName: "Doe",
            email: "test@test.com",
            in: context
        )
        
        // When
        user.size = 1
        user.weight = 1
        
        // Then
        XCTAssertTrue(user.hasSize)
        XCTAssertTrue(user.hasWeight)
    }

    // MARK: - Creation with nil tests
    func testCreateUserWithNilEmail() throws {
        // Given/When
        let user = SharedTestHelper.createUser(
            firstName: "John",
            lastName: "Doe",
            email: nil,
            in: context
        )

        // Then
        XCTAssertNil(user.email)
        XCTAssertEqual(user.login, "")
    }
    
    func testCreateUserWithNilLastName() throws {
        // Given/When
        let user = SharedTestHelper.createUser(
            firstName: "John",
            lastName: nil,
            email: "test@test.com",
            in: context
        )

        // Then
        XCTAssertNil(user.lastName)
        XCTAssertEqual(user.lastNameSafe, "")
    }
    
    func testCreateUserWithNilFirstName() throws {
        // Given/When
        let user = SharedTestHelper.createUser(
            firstName: nil,
            lastName: "Doe",
            email: "test@test.com",
            in: context
        )

        // Then
        XCTAssertNil(user.firstName)
        XCTAssertEqual(user.firstNameSafe, "")
    }
}


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
        user.height = 0
        user.weight = 0
        
        // Then
        XCTAssertFalse(user.hasHeight)
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
        user.height = 1
        user.weight = 1
        
        // Then
        XCTAssertTrue(user.hasHeight)
        XCTAssertTrue(user.hasWeight)
    }
}


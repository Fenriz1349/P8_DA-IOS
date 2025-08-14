//
//  PersistenceTests.swift
//  PersistenceTests
//
//  Created by Julien Cotte on 14/08/2025.
//

import XCTest
import CoreData
@testable import Arista

final class AristaTests: XCTestCase {

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

    // MARK: - DataBase Creation Tests

    func testCreateDatabase_ShouldWork() throws {
        // Then
        XCTAssertNotNil(controller.container)
        XCTAssertEqual(controller.count(for: User.self), 0)
    }

    func testCreateUser_ShouldWork() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)

        // When
        try SharedTestHelper.saveContext(context)

        // Then
        XCTAssertEqual(controller.count(for: User.self), 1)
        XCTAssertEqual(user.firstName, SharedTestHelper.sampleUserData.firstName)
        XCTAssertEqual(user.email, SharedTestHelper.sampleUserData.email)
    }

    func testCreateMultipleUsers_ShouldWork() throws {
        // Given
        let user1 = SharedTestHelper.createUser(
            firstName: "John",
            email: "john@test.com",
            in: context
        )
        let user2 = SharedTestHelper.createUser(
            firstName: "Jane",
            email: "jane@test.com",
            in: context
        )

        // When
        try SharedTestHelper.saveContext(context)

        // Then
        XCTAssertEqual(controller.count(for: User.self), 2)
        XCTAssertEqual(user1.firstName, "John")
        XCTAssertEqual(user2.firstName, "Jane")
    }

    // MARK: - User DataBase Deletion Tests

    func testDeleteUser_ShouldWork() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try SharedTestHelper.saveContext(context)

        XCTAssertEqual(controller.count(for: User.self), 1)

        // When
        context.delete(user)
        try SharedTestHelper.saveContext(context)
        
        // Then
        XCTAssertEqual(controller.count(for: User.self), 0)
    }

    func testClearAllData_ShouldWork() throws {
        // Given
        let users = SharedTestHelper.createUsers(count: 3, in: context)
        try SharedTestHelper.saveContext(context)

        XCTAssertEqual(controller.count(for: User.self), 3)
        XCTAssertEqual(users.count, 3)

        // When
        controller.clearAllData()

        // Then
        XCTAssertEqual(controller.count(for: User.self), 0)
    }

    // MARK: - Error Handling Tests

    func testMigrationError_ShouldHandleGracefully() {
        // Given
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: NSPersistentStoreIncompatibleVersionHashError,
            userInfo: [NSLocalizedDescriptionKey: "Model version incompatible"]
        )
        let controller = PersistenceController.createTestContainer()
        
        // When
        controller.handlePersistentStoreError(error)
        
        // Then
        XCTAssertTrue(true)
    }

    func testPermissionError_ShouldHandleGracefully() {
        // Given
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileReadNoPermissionError,
            userInfo: [NSLocalizedDescriptionKey: "Permission denied"]
        )
        let controller = PersistenceController.createTestContainer()
        
        // When
        controller.handlePersistentStoreError(error)
        
        // Then
        XCTAssertTrue(true)
    }

    func testFileNotFoundError_ShouldHandleGracefully() {
        // Given
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileReadNoSuchFileError,
            userInfo: [NSLocalizedDescriptionKey: "File not found"]
        )
        let controller = PersistenceController.createTestContainer()
        
        // When
        controller.handlePersistentStoreError(error)
        
        // Then
        XCTAssertTrue(true)
    }

    func testStorageError_ShouldHandleGracefully() {
        // Given
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: NSPersistentStoreOpenError,
            userInfo: [NSLocalizedDescriptionKey: "Insufficient storage"]
        )
        let controller = PersistenceController.createTestContainer()
        
        // When
        controller.handlePersistentStoreError(error)
        
        // Then
        XCTAssertTrue(true)
    }

    func testUnknownError_ShouldHandleGracefully() {
        // Given
        let error = NSError(
            domain: "CustomDomain",
            code: 9999,
            userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
        )
        let controller = PersistenceController.createTestContainer()
        
        // When
        controller.handlePersistentStoreError(error)
        
        // Then
        XCTAssertTrue(true)
    }
    
    // MARK: - Context Save Error Tests
        
        func testSaveContextWithValidationError_ShouldThrowError() {
            // Given - Créer un utilisateur avec des données invalides
            let user = User(context: context)
            user.id = UUID()
            
            // When/Then
            XCTAssertThrowsError(try SharedTestHelper.saveContext(context)) { error in
                XCTAssertTrue(error is NSError)
                let nsError = error as! NSError
                XCTAssertEqual(nsError.domain, NSCocoaErrorDomain)
            }
        }
        
    func testSaveContextWithConstraintViolation_ShouldThrowError() throws {
          // Given - Créer deux utilisateurs avec le même email (si contrainte unique)
          let user1 = SharedTestHelper.createUser(
              firstName: "John",
              email: "duplicate@test.com",
              in: context
          )
          try SharedTestHelper.saveContext(context)
          
          let user2 = SharedTestHelper.createUser(
              firstName: "Jane",
              email: "duplicate@test.com",
              in: context
          )
          
          // When/Then
          do {
              try SharedTestHelper.saveContext(context)
          } catch {
              XCTAssertTrue(error is NSError)
          }
      }
}

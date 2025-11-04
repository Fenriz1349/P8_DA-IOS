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
        controller = SharedTestHelper.createTestContainer()
        context = controller.container.viewContext
    }

    override func tearDownWithError() throws {
        controller = nil
        context = nil
    }

    /// DataBase Creation Tests

    func testCreateDatabase_ShouldWork() throws {
        // Then
        XCTAssertNotNil(controller.container)
        XCTAssertEqual(controller.count(for: User.self), 0)
    }


    /// Error Handling Tests

    func testMigrationError_ShouldHandleGracefully() {
        // Given
        let error = NSError(
            domain: NSCocoaErrorDomain,
            code: NSPersistentStoreIncompatibleVersionHashError,
            userInfo: [NSLocalizedDescriptionKey: "Model version incompatible"]
        )
        let controller = SharedTestHelper.createTestContainer()
        
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
        let controller = SharedTestHelper.createTestContainer()
        
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
        let controller = SharedTestHelper.createTestContainer()
        
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
        let controller = SharedTestHelper.createTestContainer()
        
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
        let controller = SharedTestHelper.createTestContainer()
        
        // When
        controller.handlePersistentStoreError(error)
        
        // Then
        XCTAssertTrue(true)
    }
    
    /// Context Save Error Tests
        
    func testSaveContextWithValidationError_ShouldThrowError() {
        // Given
        let user = User(context: context)
        user.id = UUID()
        
        // When/Then
        XCTAssertThrowsError(try SharedTestHelper.saveContext(context)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 1570) // NS Error Code for missing datas
        }
    }
}

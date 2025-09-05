//
//  UserDataManager+PasswordTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 05/09/2025.
//

import Foundation
import XCTest
import CoreData
@testable import Arista

final class UserDataManagerPasswordTests: XCTestCase {
    
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
    
    func testChangePassword_saltIsChanged() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let newPassword = "newSecret123"
        let oldSalt = user.safeSalt
        
        // When
        try manager.changePassword(for: user, currentPassword: "password", newPassword: newPassword)
        
        // Then
        XCTAssertNotEqual(oldSalt, user.safeSalt)
    }
    
    func testChangePassword_hashIsChanged() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let newPassword = "newSecret123"
        let oldHash = user.safePassword
        
        // When
        try manager.changePassword(for: user, currentPassword: "password", newPassword: newPassword)
        
        // Then
        XCTAssertNotEqual(oldHash, user.safePassword)
    }
    
    func testChangePassword_invalidCurrentPassword_ThrowsError() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        
        // When/Then
        XCTAssertThrowsError(try manager.changePassword(for: user, currentPassword: "wrongPassword", newPassword: "newSecret123")) { error in
            XCTAssertEqual(error as? PasswordChangeError, .invalidCurrentPassword)
        }
    }
    
    func testChangePassword_sameInput_throwError() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        
        // When/Then
        XCTAssertThrowsError(try manager.changePassword(for: user, currentPassword: "password", newPassword: "password")) { error in
            XCTAssertEqual(error as? PasswordChangeError, .sameAsCurrentPassword)
        }
    }
    
    func testChangePassword_validInput_Success() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let newPassword = "newSecret123"
        
        // When
        try manager.changePassword(for: user, currentPassword: "password", newPassword: newPassword)
        
        // Then
        let savedUser = try manager.fetchUser(by: user.id!)
        XCTAssertTrue(savedUser.verifyPassword(newPassword))
        XCTAssertFalse(savedUser.verifyPassword( "password"))
    }
}


//
//  User+PasswordTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import XCTest
import CoreData
@testable import Arista

final class UserPasswordTests: XCTestCase {
    
    func testVerifyPassword_correctPassword_returnsTrue() {
        // Given
        let context = PersistenceController(inMemory: true).container.viewContext
        let user = SharedTestHelper.createSampleUser(in: context)
        let correctPassword = SharedTestHelper.sampleUserData.password

        // When / Then
        XCTAssertTrue(user.verifyPassword(correctPassword))
    }

    func testVerifyPassword_incorrectPassword_returnsFalse() {
        // Given
        let context = PersistenceController(inMemory: true).container.viewContext
        let user = SharedTestHelper.createSampleUser(in: context)
        let incorrectPassword = "wrongPassword"

        // When / Then
        XCTAssertFalse(user.verifyPassword(incorrectPassword))
    }
}

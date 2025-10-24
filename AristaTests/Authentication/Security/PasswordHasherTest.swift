//
//  PasswordHasherTest.swift
//  AristaTests
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import XCTest
@testable import Arista

final class PasswordHasherTest: XCTestCase {

    func testHash_producesHash() {
        let salt = UUID()
        let hash = PasswordHasher.hash(password: "secret", salt: salt)
        XCTAssertTrue(PasswordHasher.isValidSHA256Hash(hash))
    }

    func testHash_samePasswordSameSalt_producesSameHash() {
        let salt = UUID()
        let hash1 = PasswordHasher.hash(password: "secret", salt: salt)
        let hash2 = PasswordHasher.hash(password: "secret", salt: salt)
        XCTAssertEqual(hash1, hash2)
    }

    func testHash_samePasswordDifferentSalt_producesDifferentHash() {
        let hash1 = PasswordHasher.hash(password: "secret", salt: UUID())
        let hash2 = PasswordHasher.hash(password: "secret", salt: UUID())
        XCTAssertNotEqual(hash1, hash2)
    }

    func testVerify_correctPassword_returnsTrue() {
        let salt = UUID()
        let hash = PasswordHasher.hash(password: "secret", salt: salt)
        XCTAssertTrue(PasswordHasher.verify(password: "secret", salt: salt, against: hash))
    }

    func testVerify_incorrectPassword_returnsFalse() {
        let salt = UUID()
        let hash = PasswordHasher.hash(password: "secret", salt: salt)
        XCTAssertFalse(PasswordHasher.verify(password: "secrets", salt: salt, against: hash))
    }
}

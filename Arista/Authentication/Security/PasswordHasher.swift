//
//  PasswordHasher.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import CryptoKit

final class PasswordHasher {

    /// Hashes a password with a salt using SHA-256 algorithm
    /// - Parameters:
    ///   - password: The plain text password to hash
    ///   - salt: A unique UUID used as salt for the hash
    /// - Returns: A 64-character hexadecimal string representing the SHA-256 hash
    static func hash(password: String, salt: UUID) -> String {
        let input = password + salt.uuidString
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    /// Verifies if a password matches a stored hash
    /// - Parameters:
    ///   - password: The plain text password to verify
    ///   - salt: The salt used in the original hash
    ///   - hash: The stored hash to compare against
    /// - Returns: True if the password matches the hash, false otherwise
    static func verify(password: String, salt: UUID, against hash: String) -> Bool {
        let newHash = Self.hash(password: password, salt: salt)
        return newHash == hash
    }

    /// Validates if a string is a valid SHA-256 hash format (64 hex characters)
    /// - Parameter value: The string to validate
    /// - Returns: True if the string is a valid 64-character hexadecimal hash
    static func isValidSHA256Hash(_ value: String) -> Bool {
        let regex = "^[a-f0-9]{64}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }
}

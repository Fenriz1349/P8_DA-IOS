//
//  PasswordHasher.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import CryptoKit

class PasswordHasher {
    static func hash(password: String, salt: UUID) -> String {
        let input = password + salt.uuidString
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    static func verify(password: String, salt: UUID, against hash: String) -> Bool {
        let newHash = Self.hash(password: password, salt: salt)
        return newHash == hash
    }

    static func isValidSHA256Hash(_ value: String) -> Bool {
        let regex = "^[a-f0-9]{64}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }
}

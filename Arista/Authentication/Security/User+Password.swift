//
//  User+Password.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation

extension User {

    /// Verifies if a provided password matches the user's stored hashed password
    /// - Parameter password: The plain text password to verify
    /// - Returns: True if the password is correct, false otherwise
    func verifyPassword(_ password: String) -> Bool {
        return PasswordHasher.verify(password: password, salt: self.salt, against: self.hashPassword)
    }
}

//
//  UserDataManager+Password.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import Foundation

enum PasswordChangeError: Error, Equatable {
    case sameAsCurrentPassword
    case invalidCurrentPassword
}

extension UserDataManager {

    /// Changes a user's password after verifying the current password
    /// - Parameters:
    ///   - user: The user whose password will be changed
    ///   - currentPassword: The user's current password for verification
    ///   - newPassword: The new password to set
    /// - Throws: `PasswordChangeError.invalidCurrentPassword` or `PasswordChangeError.sameAsCurrentPassword`
    func changePassword(for user: User, currentPassword: String, newPassword: String) throws {
        guard user.verifyPassword(currentPassword) else {
            throw PasswordChangeError.invalidCurrentPassword
        }

        try updatePassword(for: user, newPassword)
    }

    /// Updates a user's password with a new hashed value and regenerated salt
    /// - Parameters:
    ///   - user: The user whose password will be updated
    ///   - password: The new plain text password
    /// - Throws: `PasswordChangeError.sameAsCurrentPassword` if new password matches current
    func updatePassword(for user: User, _ password: String) throws {
        if user.verifyPassword(password) {
            throw PasswordChangeError.sameAsCurrentPassword
        }

        let builder = UserUpdateBuilder(user: user, dataManager: self)
        try builder
            .salt()
            .password(PasswordHasher.hash(password: password, salt: user.salt))
            .save()
    }
}

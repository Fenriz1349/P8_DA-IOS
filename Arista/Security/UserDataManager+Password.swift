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

    func changePassword(for user: User, currentPassword: String, newPassword: String) throws {
        // For safety always verify the current Password before update it
        guard user.verifyPassword(currentPassword) else {
            throw PasswordChangeError.invalidCurrentPassword
        }

        try updatePassword(for: user, newPassword)
    }

    func updatePassword(for user: User, _ password: String) throws {
        if user.verifyPassword(password) {
            throw PasswordChangeError.sameAsCurrentPassword
        }

        let builder = UserUpdateBuilder(user: user, dataManager: self)
        try builder
            .salt()
            .password(PasswordHasher.hash(password: password, salt: user.safeSalt))
            .save()
    }
}

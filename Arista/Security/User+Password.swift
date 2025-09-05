//
//  User+Password.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation

extension User {

    func verifyPassword(_ password: String) -> Bool {
        return PasswordHasher.verify(password: password, salt: self.safeSalt, against: self.hashPassword ?? "")
    }
}

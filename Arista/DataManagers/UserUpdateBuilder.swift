//
//  UserUpdateBuilder.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import CoreData

enum UserUpdateBuilderError: Error, Equatable {
    case emptyFirstName
    case emptyLastName
    case emptyEmail
}

class UserUpdateBuilder {
    private let user: User
    private let dataManager: UserDataManager

    init(user: User, dataManager: UserDataManager) {
        self.user = user
        self.dataManager = dataManager
    }

    @discardableResult
    func firstName(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyFirstName
        }
        user.firstName = value
        return self
    }

    @discardableResult
    func lastName(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyLastName
        }
        user.lastName = value
        return self
    }

    @discardableResult
    func email(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyEmail
        }
        user.email = value
        return self
    }

    @discardableResult
    func isLogged(_ value: Bool) throws -> UserUpdateBuilder {
        user.isLogged = value
        return self
    }

    func save() throws {
        try dataManager.viewContext.save()
    }
}

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
    case emptyPassword
    case nullCalorieGoal
    case nullSleepGoal
    case nullWaterGoal
    case invalidBirthDate
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
    func gender(_ value: Gender) -> UserUpdateBuilder {
        user.gender = value.rawValue
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
    func password(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyPassword
        }
        user.hashPassword = value
        return self
    }

    @discardableResult
    func salt() -> UserUpdateBuilder {
        user.salt = UUID()
        return self
    }

    @discardableResult
    func isLogged(_ value: Bool) -> UserUpdateBuilder {
        user.isLogged = value
        return self
    }

    @discardableResult
    func calorieGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value > 0 else {
            throw UserUpdateBuilderError.nullCalorieGoal
        }
        user.calorieGoal = Int64(value)
        return self
    }

    @discardableResult
    func sleepGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value > 0 else {
            throw UserUpdateBuilderError.nullSleepGoal
        }
        user.sleepGoal = Int64(value)
        return self
    }

    @discardableResult
    func waterGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value > 0 else {
            throw UserUpdateBuilderError.nullWaterGoal
        }
        user.waterGoal = Int64(value)
        return self
    }

    @discardableResult
    func height(_ value: Int) throws -> UserUpdateBuilder {
        guard value > 0 else {
            throw UserUpdateBuilderError.nullWaterGoal
        }
        user.height = Int64(value)
        return self
    }

    @discardableResult
    func weight(_ value: Int) throws -> UserUpdateBuilder {
        guard value > 0 else {
            throw UserUpdateBuilderError.nullWaterGoal
        }
        user.weight = Int64(value)
        return self
    }

    @discardableResult
    func birthDate(_ value: Date) -> UserUpdateBuilder {
        user.birthdate = value
        return self
    }

    func save() throws {
        try dataManager.viewContext.save()
    }
}

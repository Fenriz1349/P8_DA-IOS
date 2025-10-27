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
    case emptyPassword
    case negativeCalorieGoal
    case negativeSleepGoal
    case negativeWaterGoal
    case negativeStepsGoal
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
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeCalorieGoal
        }
        user.calorieGoal = Int16(value)
        return self
    }

    @discardableResult
    func sleepGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeSleepGoal
        }
        user.sleepGoal = Int16(value)
        return self
    }

    @discardableResult
    func waterGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeWaterGoal
        }
        user.waterGoal = Int16(value)
        return self
    }
    
    @discardableResult
    func stepsGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeStepsGoal
        }
        user.stepsGoal = Int32(value)
        return self
    }

    func save() throws {
        try dataManager.viewContext.save()
    }
}

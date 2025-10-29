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

    /// Updates the user's first name
    /// - Parameter value: The new first name (must not be empty)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.emptyFirstName if the value is empty
    @discardableResult
    func firstName(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyFirstName
        }
        user.firstName = value
        return self
    }

    /// Updates the user's last name
    /// - Parameter value: The new last name (must not be empty)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.emptyLastName if the value is empty
    @discardableResult
    func lastName(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyLastName
        }
        user.lastName = value
        return self
    }

    /// Updates the user's password hash
    /// - Parameter value: The new password hash (must not be empty)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.emptyPassword if the value is empty
    @discardableResult
    func password(_ value: String) throws -> UserUpdateBuilder {
        guard !value.isEmpty else {
            throw UserUpdateBuilderError.emptyPassword
        }
        user.hashPassword = value
        return self
    }

    /// Generates a new salt for the user
    /// - Returns: Self for method chaining
    @discardableResult
    func salt() -> UserUpdateBuilder {
        user.salt = UUID()
        return self
    }

    /// Updates the user's logged-in status
    /// - Parameter value: The new logged-in status
    /// - Returns: Self for method chaining
    @discardableResult
    func isLogged(_ value: Bool) -> UserUpdateBuilder {
        user.isLogged = value
        return self
    }

    /// Updates the user's daily calorie goal
    /// - Parameter value: The new calorie goal in kcal (must be non-negative)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.negativeCalorieGoal if the value is negative
    @discardableResult
    func calorieGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeCalorieGoal
        }
        user.calorieGoal = Int16(value)
        return self
    }

    /// Updates the user's daily sleep goal
    /// - Parameter value: The new sleep goal in minutes (must be non-negative)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.negativeSleepGoal if the value is negative
    @discardableResult
    func sleepGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeSleepGoal
        }
        user.sleepGoal = Int16(value)
        return self
    }

    /// Updates the user's daily water goal
    /// - Parameter value: The new water goal in deciliters (must be non-negative)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.negativeWaterGoal if the value is negative
    @discardableResult
    func waterGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeWaterGoal
        }
        user.waterGoal = Int16(value)
        return self
    }
    
    /// Updates the user's daily steps goal
    /// - Parameter value: The new steps goal (must be non-negative)
    /// - Returns: Self for method chaining
    /// - Throws: UserUpdateBuilderError.negativeStepsGoal if the value is negative
    @discardableResult
    func stepsGoal(_ value: Int) throws -> UserUpdateBuilder {
        guard value >= 0 else {
            throw UserUpdateBuilderError.negativeStepsGoal
        }
        user.stepsGoal = Int32(value)
        return self
    }

    /// Saves all changes to the user in the Core Data context
    /// - Throws: Error if the context cannot be saved
    func save() throws {
        try dataManager.viewContext.save()
    }
}

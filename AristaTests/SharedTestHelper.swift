//
//  SharedTestHelper.swift
//  AristaTests
//
//  Created by Julien Cotte on 14/08/2025.
//

import Foundation
import CoreData
@testable import Arista

struct SharedTestHelper {

    /// Create an unique PersistenceController for each test
    static func createTestContainer() -> PersistenceController {
        return PersistenceController(inMemory: true)
    }

    // MARK: - Sample Data
    static let sampleUserData = (
        firstName: "John",
        lastName: "Cena",
        email: "john.Cena@test.com",
        password: "Password123!"
    )

    static let sampleUserData2 = (
        firstName: "Jane",
        lastName: "Cena",
        email: "jane.Cena@test.com",
        password: "Password123!"
    )

    // MARK: - User Creation Helpers

    static func createSampleUser(in context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.salt = UUID()
        user.firstName = sampleUserData.firstName
        user.lastName = sampleUserData.lastName
        user.email = sampleUserData.email
        user.hashPassword = PasswordHasher.hash(password: sampleUserData.password, salt: user.salt)
        return user
    }

    static func createSampleUser2(in context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.salt = UUID()
        user.firstName = sampleUserData2.firstName
        user.lastName = sampleUserData2.lastName
        user.email = sampleUserData2.email
        user.hashPassword = PasswordHasher.hash(password: sampleUserData2.password, salt: user.salt)
        return user
    }

    static func createUser(
        firstName: String,
        lastName: String,
        email: String,
        in context: NSManagedObjectContext
    ) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        return user
    }

    static func createUsers(count: Int, in context: NSManagedObjectContext) -> [User] {
        var users: [User] = []

        for i in 1...count {
            let user = User(context: context)
            user.id = UUID()
            user.firstName = "User\(i)"
            user.email = "user\(i)@test.com"
            users.append(user)
        }

        return users
    }
    static func createRandomUsers(in context: NSManagedObjectContext) -> [User] {
        let randomCount: Int = Int.random(in: 1...100)
        return createUsers(count: randomCount, in: context)
    }
    
    static func createInvalidUser(in context: NSManagedObjectContext) -> User {
           let user = User(context: context)
           user.id = UUID()
           return user
       }
    
    static func saveContextWithErrorHandling(_ context: NSManagedObjectContext) -> Error? {
            do {
                try context.save()
                return nil
            } catch {
                return error
            }
        }

    // MARK: - Save Helper

    static func saveContext(_ context: NSManagedObjectContext) throws {
        try context.save()
    }
}

extension SharedTestHelper {
    static func createSampleExercice(for user: User,
                                     in context: NSManagedObjectContext,
                                     date: Date = Date(),
                                     duration: Int = 30,
                                     type: ExerciceType = .running,
                                     intensity: Int = 5) -> Exercice {
        let exercice = Exercice(context: context)
        exercice.id = UUID()
        exercice.date = date
        exercice.duration = Int16(duration)
        exercice.intensity = Int16(intensity)
        exercice.type = type.rawValue
        exercice.user = user
        return exercice
    }
}


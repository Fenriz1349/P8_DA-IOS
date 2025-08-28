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

    // MARK: - Sample Data
    static let sampleUserData = (
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@test.com"
    )

    static let sampleUserData2 = (
        firstName: "Jane",
        lastName: "Smith",
        email: "jane.smith@test.com"
    )

    // MARK: - User Creation Helpers

    static func createSampleUser(in context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.firstName = sampleUserData.firstName
        user.lastName = sampleUserData.lastName
        user.email = sampleUserData.email
        return user
    }

    static func createUser(
        firstName: String?,
        lastName: String?,
        email: String?,
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
    
    static func createInvalidUser(in context: NSManagedObjectContext) -> User {
           let user = User(context: context)
           user.id = UUID()
           // Délibérément omettre les champs requis
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

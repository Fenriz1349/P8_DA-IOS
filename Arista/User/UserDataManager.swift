//
//  UserDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 28/08/2025.
//

import Foundation
import CoreData

enum UserDataManagerError: Error, Equatable, LocalizedError {
    case invalidInput
    case userNotFound
    case noLoggedUser
    case emailAlreadyUsed

    var errorDescription: String? {
        switch self {
        case .invalidInput: return String(localized: "error.user.invalidInput")
        case .userNotFound: return String(localized: "error.user.userNotFound")
        case .noLoggedUser: return String(localized: "error.user.noLoggedUser")
        case .emailAlreadyUsed: return String(localized: "error.auth.emailAlreadyUsed")
        }
    }
}

final class UserDataManager {

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    /// Creates a new user with the provided credentials and personal information
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (will be hashed)
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    /// - Returns: The newly created User entity
    /// - Throws: UserDataManagerError if validation fails or email already exists
    @discardableResult
    func createUser(email: String, password: String, firstName: String, lastName: String) throws -> User {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            throw UserDataManagerError.invalidInput
        }

        let context = container.viewContext

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        guard try context.fetch(request).isEmpty else {
            throw UserDataManagerError.emailAlreadyUsed
        }

        let user = User(context: context)
        user.email = email
        user.id = UUID()
        user.salt = UUID()
        user.hashPassword = PasswordHasher.hash(password: password, salt: user.salt)
        user.firstName = firstName
        user.lastName = lastName

        try context.save()

        return user
    }

    /// Fetches a user by their unique identifier
    /// - Parameter id: The UUID of the user to fetch
    /// - Returns: The User entity matching the provided ID
    /// - Throws: UserDataManagerError.userNotFound if no user exists with the given ID
    func fetchUser(by id: UUID) throws -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let user = try context.fetch(request).first else {
            throw UserDataManagerError.userNotFound
        }
        return user
    }

    /// Fetches the currently logged-in user
    /// - Returns: The User entity marked as logged in
    /// - Throws: UserDataManagerError.noLoggedUser if no user is currently logged in
    func fetchLoggedUser() throws -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "isLogged == true")
        guard let user = try context.fetch(request).first else {
            throw UserDataManagerError.noLoggedUser
        }
        return user
    }

    /// Fetches all users from the database
    /// - Returns: An array of all User entities, or an empty array if none exist
    func fetchAllUsers() -> [User] {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        guard let users = try? context.fetch(request) else {
            return []
        }
        return users
    }

    /// Logs in a user by their ID, logging out all other users
    /// - Parameter id: The UUID of the user to log in
    /// - Throws: UserDataManagerError if the user is not found or cannot be updated
    func loggedIn(id: UUID) throws {
        try loggedOffAllUsers()
        let user = try fetchUser(by: id)
        let builder = UserUpdateBuilder(user: user, dataManager: self)
        try builder.isLogged(true).save()
    }

    /// Logs out all users by setting their isLogged flag to false
    /// - Throws: Error if the context cannot be saved
    func loggedOffAllUsers() throws {
        let context = container.viewContext
        let users = fetchAllUsers()
        for user in users { user.isLogged = false }
        try context.save()
    }

    /// Deletes a user from the database
    /// - Parameter id: The UUID of the user to delete
    /// - Throws: UserDataManagerError if the user is not found or cannot be deleted
    func deleteUser(by id: UUID) throws {
        let user = try fetchUser(by: id)
        let context = container.viewContext
        context.delete(user)
        try context.save()
    }
}

#if DEBUG
extension UserDataManager {
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    var allUsers: [User] {
        return fetchAllUsers()
    }
}
#endif

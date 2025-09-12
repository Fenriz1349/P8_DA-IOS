//
//  UserDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 28/08/2025.
//

import Foundation
import CoreData

enum UserDataManagerError: Error, Equatable {
    case invalidInput
    case userNotFound
    case noLoggedUser
}

final class UserDataManager {

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    var noUserLogged: Bool {
        fetchAllUsers().allSatisfy { $0.isLogged == false }
    }

    // MARK: - User Creation Method
    func createUser(email: String, password: String, firstName: String, lastName: String) throws -> User {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            throw UserDataManagerError.invalidInput
        }
        let context = container.viewContext
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

    // MARK: - Users Fetching Methods
    func fetchUser(by id: UUID) throws -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        guard let user = try? context.fetch(request).first else {
            throw UserDataManagerError.userNotFound
        }
        return user
    }

    func fetchLoggedUser() throws -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "isLogged== true", )
        guard let user = try? context.fetch(request).first else {
            throw UserDataManagerError.noLoggedUser
        }
        return user
    }

    func fetchAllUsers() -> [User] {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        guard let users = try? context.fetch(request) else {
            return []
        }
        return users
    }

    // MARK: - Loggin In Method
    func loggedIn(id: UUID) throws {
        try loggedOffAllUsers()
        let user = try fetchUser(by: id)
        let builder = UserUpdateBuilder(user: user, dataManager: self)
        try builder.isLogged(true).save()
    }

    // MARK: - Logging Off Method
    func loggedOffAllUsers() throws {
        let users = fetchAllUsers()
        for user in users {
            let builder = UserUpdateBuilder(user: user, dataManager: self)
            try builder.isLogged(false).save()
        }
    }

    // MARK: - Delete User Method
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

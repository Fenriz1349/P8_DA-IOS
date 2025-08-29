//
//  UserDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 28/08/2025.
//

import Foundation
import CoreData

enum UserDataManagerError: Error, Equatable {
    case userNotFound
}

final class UserDataManager {

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func createUser(email: String, password: String, firstName: String, lastName: String) throws -> User {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            throw URLError(.cannotParseResponse)
        }
        let context = container.viewContext
        let user = User(context: context)
        user.email = email
        user.hashPassword = password
        user.id = UUID()
        user.salt = UUID()
        user.firstName = firstName
        user.lastName = lastName

        try context.save()

        return user
    }

    func fetchUser(by id: UUID) throws -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        guard let user = try? context.fetch(request).first else {
            throw UserDataManagerError.userNotFound
        }
        return user
    }

    private func fetchAllUsers() throws -> [User] {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        guard let users = try? context.fetch(request) else {
            throw UserDataManagerError.userNotFound
        }
        return users
    }

    // MARK: - Update User Functions
    func updateUserIsLogged(id: UUID, isLogged: Bool) throws {
        let context = container.viewContext
        guard let user = try? fetchUser(by: id) else {
            throw UserDataManagerError.userNotFound
        }
        user.isLogged = isLogged
        try context.save()
    }

    var noUserLogged: Bool {
        guard let users = try? fetchAllUsers() else {
            return true
        }
        return users.allSatisfy { $0.isLogged == false }
    }
}

#if DEBUG
extension UserDataManager {
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
#endif

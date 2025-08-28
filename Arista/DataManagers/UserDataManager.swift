//
//  UserDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 28/08/2025.
//

import Foundation
import CoreData

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
}

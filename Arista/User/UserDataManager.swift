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

    /// Fetches a user by their unique identifier
    /// - Parameter id: The UUID of the user to fetch
    /// - Returns: The User entity matching the provided ID
    /// - Throws: UserDataManagerError.userNotFound if no user exists with the given ID
    func getOrCreateUser() -> User {
        let context = container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()

        if let existingUser = try? context.fetch(request).first {
            return existingUser
        }

        let user = User(context: context)
        user.id = UUID()
        user.firstName = "Bruce"
        user.lastName = "Wayne"
        user.calorieGoal = 300
        user.sleepGoal = 480
        user.waterGoal = 25
        user.stepsGoal = 8000

        try? context.save()

        return user
    }
}

#if DEBUG
extension UserDataManager {
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
#endif

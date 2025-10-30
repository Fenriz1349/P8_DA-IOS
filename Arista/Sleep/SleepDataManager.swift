//
//  SleepDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import Foundation
import CoreData

enum SleepDataManagerError: Error, Equatable, LocalizedError {
    case sleepCycleNotFound
    case activeSessionAlreadyExists
    case invalidDateInterval

    var errorDescription: String? {
        switch self {
        case .sleepCycleNotFound: return "error.sleep.cycleNotFound".localized
        case .activeSessionAlreadyExists: return "error.sleep.activeSessionExists".localized
        case .invalidDateInterval: return "error.sleep.invalidDateInterval".localized
        }
    }
}

final class SleepDataManager {
    private let container: NSPersistentContainer
    private let userDataManager: UserDataManager

    /// Initializes the SleepDataManager with a persistent container and optional user data manager
    /// - Parameters:
    ///   - container: The Core Data persistent container (defaults to shared instance)
    ///   - userDataManager: Optional user data manager for user operations
    init(container: NSPersistentContainer = PersistenceController.shared.container,
         userDataManager: UserDataManager? = nil) {
        self.container = container
        self.userDataManager = userDataManager ?? UserDataManager(container: container)
    }

    /// Creates a new sleep cycle for the specified user
    /// - Parameters:
    ///   - user: The user for whom to create the sleep cycle
    ///   - startDate: The start date of the sleep cycle (defaults to current date)
    /// - Returns: The newly created SleepCycle entity
    /// - Throws: SleepDataManagerError.activeSessionAlreadyExists if a cycle is already active
    @discardableResult
    func startSleepCycle(for user: User, startDate: Date = Date()) throws -> SleepCycle {
        let context = container.viewContext

        guard try !hasActiveSleepCycle(for: user) else {
            throw SleepDataManagerError.activeSessionAlreadyExists
        }

        let sleepCycle = SleepCycle(context: context)
        sleepCycle.id = UUID()
        sleepCycle.dateStart = startDate
        sleepCycle.dateEnding = nil
        sleepCycle.quality = 0
        sleepCycle.user = user

        try context.save()

        return sleepCycle
    }

    /// Ends the active sleep cycle for the specified user
    /// - Parameters:
    ///   - user: The user whose active sleep cycle should be ended
    ///   - endDate: The end date of the sleep cycle (defaults to current date)
    ///   - quality: The quality rating of the sleep cycle (0-10, defaults to 0)
    /// - Returns: The updated SleepCycle entity
    /// - Throws: SleepDataManagerError if no active cycle found or dates are invalid
    @discardableResult
    func endSleepCycle(for user: User, endDate: Date = Date(), quality: Int = 0) throws -> SleepCycle {
        guard let activeCycle = try getActiveSleepCycle(for: user) else {
            throw SleepDataManagerError.sleepCycleNotFound
        }

        guard activeCycle.dateStart <= endDate else {
            throw SleepDataManagerError.invalidDateInterval
        }

        let context = container.viewContext
        activeCycle.dateEnding = endDate
        activeCycle.quality = Int16(quality)

        try context.save()

        return activeCycle
    }

    /// Fetches all sleep cycles for a specific user
    /// - Parameter user: The user whose sleep cycles to fetch
    /// - Returns: An array of SleepCycle entities sorted by start date (descending)
    /// - Throws: Error if the fetch request fails
    func fetchSleepCycles(for user: User) throws -> [SleepCycle] {
        let context = container.viewContext

        let request: NSFetchRequest<SleepCycle> = SleepCycle.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "dateStart", ascending: false)]

        return try context.fetch(request)
    }

    /// Fetches sleep cycles from the last 7 days for a specific user
    /// - Parameter user: The user whose recent sleep cycles to fetch
    /// - Returns: An array of SleepCycle entities from the last week
    /// - Throws: Error if the fetch request fails
    func fetchRecentSleepCycles(for user: User) throws -> [SleepCycle] {
        let allCycles = try fetchSleepCycles(for: user)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        return allCycles.filter { $0.dateStart >= sevenDaysAgo }
    }

    /// Checks if the user has an active sleep cycle
    /// - Parameter user: The user to check
    /// - Returns: True if an active sleep cycle exists, false otherwise
    /// - Throws: Error if the fetch request fails
    func hasActiveSleepCycle(for user: User) throws -> Bool {
        return try getActiveSleepCycle(for: user) != nil
    }

    /// Retrieves the active sleep cycle for a specific user
    /// - Parameter user: The user whose active sleep cycle to fetch
    /// - Returns: The active SleepCycle entity, or nil if none exists
    /// - Throws: Error if the fetch request fails
    func getActiveSleepCycle(for user: User) throws -> SleepCycle? {
        let context = container.viewContext
        let request: NSFetchRequest<SleepCycle> = SleepCycle.fetchRequest()

        request.predicate = NSPredicate(
            format: "user.id == %@ AND dateEnding == nil",
            user.id as CVarArg
        )
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    /// Deletes a specific sleep cycle from the database
    /// - Parameter sleepCycle: The SleepCycle entity to delete
    /// - Throws: Error if the context cannot be saved
    func deleteSleepCycle(_ sleepCycle: SleepCycle) throws {
        let context = container.viewContext
        context.delete(sleepCycle)
        try context.save()
    }

    /// Updates an existing sleep cycle with new values
    /// - Parameters:
    ///   - id: The UUID of the sleep cycle to update
    ///   - startDate: The new start date
    ///   - endDate: The new end date
    ///   - quality: The new quality rating (0-10)
    /// - Throws: SleepDataManagerError.sleepCycleNotFound if the cycle doesn't exist
    func updateSleepCycle(by id: UUID, startDate: Date, endDate: Date, quality: Int) throws {
        let context = container.viewContext
        let request: NSFetchRequest<SleepCycle> = SleepCycle.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        guard let cycle = try context.fetch(request).first else {
            throw SleepDataManagerError.sleepCycleNotFound
        }

        cycle.dateStart = startDate
        cycle.dateEnding = endDate
        cycle.quality = Int16(quality)

        try context.save()
    }

}

#if DEBUG
extension SleepDataManager {
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
#endif

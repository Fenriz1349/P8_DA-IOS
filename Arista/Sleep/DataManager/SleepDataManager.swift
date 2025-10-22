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
        case .sleepCycleNotFound: return "Aucun cycle de sommeil actif trouvé."
        case .activeSessionAlreadyExists: return "Un cycle de sommeil est déjà en cours."
        case .invalidDateInterval: return "Les dates fournies ne sont pas valides."
        }
    }
}

final class SleepDataManager {
    private let container: NSPersistentContainer
    private let userDataManager: UserDataManager

    init(container: NSPersistentContainer = PersistenceController.shared.container,
         userDataManager: UserDataManager? = nil) {
        self.container = container
        self.userDataManager = userDataManager ?? UserDataManager(container: container)
    }

    /// Create Sleep Cycle
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

    func endSleepCycle(for user: User, endDate: Date = Date(), quality: Int16 = 0) throws -> SleepCycle {
        guard let activeCycle = try getActiveSleepCycle(for: user) else {
            throw SleepDataManagerError.sleepCycleNotFound
        }

        guard activeCycle.dateStart <= endDate else {
            throw SleepDataManagerError.invalidDateInterval
        }

        let context = container.viewContext
        activeCycle.dateEnding = endDate
        activeCycle.quality = quality

        try context.save()

        return activeCycle
    }

    /// Fetch Methods
    func fetchSleepCycles(for user: User) throws -> [SleepCycle] {
        let context = container.viewContext

        let request: NSFetchRequest<SleepCycle> = SleepCycle.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "dateStart", ascending: false)]

        return try context.fetch(request)
    }

    func fetchRecentSleepCycles(for user: User) throws -> [SleepCycle] {
        let allCycles = try fetchSleepCycles(for: user)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        return allCycles.filter { $0.dateStart >= sevenDaysAgo }
    }

    func hasActiveSleepCycle(for user: User) throws -> Bool {
        return try getActiveSleepCycle(for: user) != nil
    }

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

    /// Delete Methods
    func deleteSleepCycle(_ sleepCycle: SleepCycle) throws {
        let context = container.viewContext
        context.delete(sleepCycle)
        try context.save()
    }

    /// Update Methods
    func updateSleepCycle(
        by id: UUID,
        startDate: Date,
        endDate: Date,
        quality: Int16
    ) throws {
        let context = container.viewContext
        let request: NSFetchRequest<SleepCycle> = SleepCycle.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        guard let cycle = try context.fetch(request).first else {
            throw SleepDataManagerError.sleepCycleNotFound
        }

        cycle.dateStart = startDate
        cycle.dateEnding = endDate
        cycle.quality = quality

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

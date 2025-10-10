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
        case .sleepCycleNotFound:
            return "Aucun cycle de sommeil actif trouvé."
        case .activeSessionAlreadyExists:
            return "Un cycle de sommeil est déjà en cours."
        case .invalidDateInterval:
            return "Les dates fournies ne sont pas valides."
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

    // MARK: - Create Sleep Cycle
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
        context.refresh(activeCycle, mergeChanges: true)

        return activeCycle
    }

    // MARK: - Fetch Methods
    func fetchSleepCycles(for user: User, limit: Int? = nil) throws -> [SleepCycle] {
        let context = container.viewContext
        let request: NSFetchRequest<SleepCycle> = SleepCycle.fetchRequest()

        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "dateStart", ascending: false)]
        if let limit = limit {
            request.fetchLimit = limit
        }

        return try context.fetch(request)
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

    // MARK: - Delete Methods
    func deleteSleepCycle(_ sleepCycle: SleepCycle) throws {
        let context = container.viewContext
        context.delete(sleepCycle)
        try context.save()
        context.refreshAllObjects()
    }

    // MARK: - Update Methods
    func updateSleepQuality(for sleepCycle: SleepCycle, quality: Int16) throws {
        guard sleepCycle.dateEnding != nil else {
            throw SleepDataManagerError.sleepCycleNotFound
        }

        let context = container.viewContext
        sleepCycle.quality = quality
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

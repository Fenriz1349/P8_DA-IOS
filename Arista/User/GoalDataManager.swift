//
//  GoalDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 23/10/2025.
//

import Foundation
import CoreData

enum GoalDataManagerError: Error, LocalizedError, Equatable {
    case goalNotFound
    case failedToSave

    var errorDescription: String? {
        switch self {
        case .goalNotFound: return "Aucun objectif trouvé pour la date spécifiée."
        case .failedToSave: return "Impossible d'enregistrer l'objectif."
        }
    }
}

final class GoalDataManager {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func createOrUpdate(for user: User, date: Date = Date(), amount: Int16) throws -> Goal {
        let context = container.viewContext
        
        let normalizedDate = Calendar.current.date(from: date.ymdComponents)!
        
        let goal: Goal
        if let existingGoal = try findGoal(for: user, date: date) {
            goal = existingGoal
            goal.totalWater += amount
        } else {
            goal = Goal(context: context)
            goal.id = UUID()
            goal.date = normalizedDate
            goal.user = user
            goal.totalWater = amount
        }

        do {
            try context.save()
            return goal
        } catch {
            throw GoalDataManagerError.failedToSave
        }
    }
    
    /// Fetch Methods
    private func findGoal(for user: User, date: Date) throws -> Goal? {
        let context = container.viewContext
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        
        let allGoals = try context.fetch(request)
        return allGoals.first { $0.date.isSameDay(as: date) }
    }

    func fetchGoals(for user: User) throws -> [Goal] {
        let context = container.viewContext
        
        print("\n🔍 fetchGoals DEBUG:")
        print("   Context has changes: \(context.hasChanges)")
        print("   Inserted objects: \(context.insertedObjects.count)")
        print("   Updated objects: \(context.updatedObjects.count)")
        print("   Deleted objects: \(context.deletedObjects.count)")
        
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        // Essayez avec includesPendingChanges
        request.includesPendingChanges = true
        
        let results = try context.fetch(request)
        print("   Fetched \(results.count) goals")
        
        return results
    }

    func fetchLastWeekGoals(for user: User) throws -> [Goal] {
        let allGoals = try fetchGoals(for: user)
        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return allGoals
        }
        return allGoals.filter { $0.date >= oneWeekAgo }
    }

    func fetchGoal(for user: User, date: Date) throws -> Goal {
        guard let goal = try findGoal(for: user, date: date) else {
            throw GoalDataManagerError.goalNotFound
        }
        return goal
    }

    func deleteGoal(_ goal: Goal) throws {
        let context = container.viewContext
        context.delete(goal)
        do {
            try context.save()
        } catch {
            throw GoalDataManagerError.failedToSave
        }
    }
}

#if DEBUG
extension GoalDataManager {
    var viewContext: NSManagedObjectContext { container.viewContext }
}
#endif

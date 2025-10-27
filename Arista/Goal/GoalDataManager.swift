//
//  GoalDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 23/10/2025.
//

import Foundation
import CoreData

final class GoalDataManager {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func updateWater(for user: User, date: Date = Date(), newWater: Int16) throws -> Goal {
        let context = container.viewContext
        let normalizedDate = Calendar.current.date(from: date.ymdComponents)!

        let goal: Goal
        if let existingGoal = try fetchGoal(for: user, date: date) {
            goal = existingGoal
            goal.totalWater = newWater
        } else {
            goal = Goal(context: context)
            goal.id = UUID()
            goal.date = normalizedDate
            goal.user = user
            goal.totalWater = newWater
        }

        try context.save()
        return goal
    }

    func updateSteps(for user: User, date: Date = Date(), newSteps: Int32) throws -> Goal {
        let context = container.viewContext
        let normalizedDate = Calendar.current.date(from: date.ymdComponents)!

        let goal: Goal
        if let existingGoal = try fetchGoal(for: user, date: date) {
            goal = existingGoal
            goal.totalSteps = newSteps
        } else {
            goal = Goal(context: context)
            goal.id = UUID()
            goal.date = normalizedDate
            goal.user = user
            goal.totalSteps = newSteps
        }

        try context.save()
        return goal
    }

    /// Fetch Methods
    func fetchGoal(for user: User, date: Date = Date()) throws -> Goal? {
        let context = container.viewContext
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)

        let allGoals = try context.fetch(request)
        return allGoals.first(where: { $0.date.isSameDay(as: date) })
    }

    func fetchGoals(for user: User) throws -> [Goal] {
        let context = container.viewContext

        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let results = try context.fetch(request)

        return results
    }

    func fetchLastWeekGoals(for user: User) throws -> [Goal] {
        let allGoals = try fetchGoals(for: user)
        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return allGoals
        }
        return allGoals.filter { $0.date >= oneWeekAgo }
    }

    @discardableResult
    func fetchOrCreateGoal(for user: User, date: Date) throws -> Goal {
        let context = container.viewContext
        let normalizedDate = Calendar.current.date(from: date.ymdComponents)!

        if let existing = try fetchGoal(for: user, date: date) {
            return existing
        } else {
            let newGoal = Goal(context: context)
            newGoal.id = UUID()
            newGoal.date = normalizedDate
            newGoal.user = user
            newGoal.totalWater = 0
            newGoal.totalSteps = 0
            try context.save()
            return newGoal
        }
    }

    func deleteGoal(_ goal: Goal) throws {
        let context = container.viewContext
        context.delete(goal)
        try context.save()
    }
}

#if DEBUG
extension GoalDataManager {
    var viewContext: NSManagedObjectContext { container.viewContext }
}
#endif

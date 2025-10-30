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

    /// Updates or creates a goal with new water consumption value
    /// - Parameters:
    ///   - user: The user for whom to update the water goal
    ///   - date: The date for which to update the goal (defaults to current date)
    ///   - newWater: The new water consumption value in deciliters
    /// - Returns: The updated or created Goal entity
    /// - Throws: Error if the context cannot be saved
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

    /// Updates or creates a goal with new steps count
    /// - Parameters:
    ///   - user: The user for whom to update the steps goal
    ///   - date: The date for which to update the goal (defaults to current date)
    ///   - newSteps: The new steps count
    /// - Returns: The updated or created Goal entity
    /// - Throws: Error if the context cannot be saved
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

    /// Fetches an existing goal for a specific user and date
    /// - Parameters:
    ///   - user: The user whose goal to fetch
    ///   - date: The date for which to fetch the goal (defaults to current date)
    /// - Returns: The matching Goal entity, or nil if not found
    /// - Throws: Error if the fetch request fails
    func fetchGoal(for user: User, date: Date = Date()) throws -> Goal? {
        let context = container.viewContext
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)

        let allGoals = try context.fetch(request)
        return allGoals.first(where: { $0.date.isSameDay(as: date) })
    }

    /// Fetches all goals for a specific user
    /// - Parameter user: The user whose goals to fetch
    /// - Returns: An array of Goal entities sorted by date (descending)
    /// - Throws: Error if the fetch request fails
    func fetchGoals(for user: User) throws -> [Goal] {
        let context = container.viewContext

        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let results = try context.fetch(request)

        return results
    }

    /// Fetches goals for the last 7 days for a specific user
    /// - Parameter user: The user whose goals to fetch
    /// - Returns: An array of Goal entities from the last week
    /// - Throws: Error if the fetch request fails
    func fetchLastWeekGoals(for user: User) throws -> [Goal] {
        let allGoals = try fetchGoals(for: user)
        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return allGoals
        }
        return allGoals.filter { $0.date >= oneWeekAgo }
    }

    /// Fetches an existing goal for a date, or creates a new one if none exists
    /// - Parameters:
    ///   - user: The user for whom to fetch or create the goal
    ///   - date: The date for which to fetch or create the goal
    /// - Returns: The existing or newly created Goal entity
    /// - Throws: Error if the context cannot be saved
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

    /// Deletes a specific goal from the database
    /// - Parameter goal: The Goal entity to delete
    /// - Throws: Error if the context cannot be saved
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

//
//  Goal.swift
//  Arista
//
//  Created by Julien Cotte on 23/10/2025.
//

import CoreData

@objc(Goal)
public class Goal: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var totalWater: Int16
    @NSManaged public var totalSteps: Int32
    @NSManaged public var user: User
}

extension Goal {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    /// Converts the Goal entity to a GoalDisplay view model
    /// - Returns: GoalDisplay instance with formatted goal data including related exercises and sleep cycles
    func toDisplay() -> GoalDisplay {
        let userExercises = user.exercices?.map { $0.toDisplay } ?? []
        let userSleepCycles = user.sleepCycles?.map { $0.toDisplay } ?? []

        return GoalDisplay(
            id: id,
            date: date,
            totalWater: Int(totalWater),
            totalSteps: Int(totalSteps),
            exercices: userExercises,
            sleepCycles: userSleepCycles
        )
    }

    /// Converts an array of Goal entities to an array of GoalDisplay view models
    /// - Parameter goals: Array of Goal entities to convert
    /// - Returns: Array of GoalDisplay instances
    static func mapToDisplay(from goals: [Goal]) -> [GoalDisplay] {
        goals.map { $0.toDisplay() }
    }
}

/// This struct is used as an overlay to always display the fresh value from CoreData
struct GoalDisplay: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let totalWater: Int
    let totalSteps: Int

    let exercices: [ExerciceDisplay]
    let sleepCycles: [SleepCycleDisplay]

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var stepsCalories: Int { Int(Double(totalSteps) * 0.04) }

    var totalCalories: Int {
        let exerciseCalories = exercices
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .map(\.caloriesBurned)
            .reduce(0, +)

        return exerciseCalories + stepsCalories
    }

    var totalSleepMinutes: Int {
        sleepCycles
            .filter { cycle in
                if let end = cycle.dateEnding {
                    return Calendar.current.isDate(end, inSameDayAs: date)
                }
                return false
            }
            .compactMap { cycle in
                guard let end = cycle.dateEnding else { return nil }
                return Int(end.timeIntervalSince(cycle.dateStart) / 60)
            }
            .reduce(0, +)
    }
}

extension GoalDisplay {
    /// Converts the GoalDisplay to a DayCalories instance
    /// - Returns: DayCalories instance with date and total calories
    func toDayCalories() -> DayCalories {
        DayCalories(
            date: date,
            calories: totalCalories
        )
    }
}

extension Array where Element == GoalDisplay {
    /// Converts an array of GoalDisplay to an array of DayCalories
    /// - Returns: Array of DayCalories instances
    func toDayCalories() -> [DayCalories] {
        self.map { $0.toDayCalories() }
    }
}

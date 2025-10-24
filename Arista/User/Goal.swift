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
    
    static func mapToDisplay(from goals: [Goal]) -> [GoalDisplay] {
        goals.map { $0.toDisplay() }
    }
}

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

    var totalCalories: Int {
        exercices
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .map(\.caloriesBurned)
            .reduce(0, +)
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

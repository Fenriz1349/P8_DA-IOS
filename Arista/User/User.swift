//
//  User+CoreDataClass.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//
//

import CoreData

@objc(User)
public class User: NSManagedObject {
    @NSManaged public var firstName: String
    @NSManaged public var id: UUID
    @NSManaged public var lastName: String
    @NSManaged public var sleepGoal: Int16
    @NSManaged public var waterGoal: Int16
    @NSManaged public var stepsGoal: Int32
    @NSManaged public var calorieGoal: Int16

    @NSManaged public var exercices: Set<Exercice>?
    @NSManaged public var sleepCycles: Set<SleepCycle>?
    @NSManaged public var goals: Set<Goal>?
}

extension User {
    /// in User goals will use this format to always use Int:
    /// calorieGoal - unit: kCal, default value: 300 kCal
    /// sleeepGoal - unit: minute, default value: 480 minutes (8hours)
    /// waterGoal - unit: deciliter, default value: 25 dl (2,5 liters)
    /// stepsGoal - unit: step, default value: 8000 steps/day

    /// Creates and returns a fetch request for User entities
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    /// Converts the User entity to a UserDisplay view model
    /// - Returns: UserDisplay instance with formatted user data
    func toDisplay() -> UserDisplay {
        UserDisplay(
            id: id,
            firstName: firstName,
            lastName: lastName,
            calorieGoal: Int(calorieGoal),
            sleepGoal: Int(sleepGoal),
            waterGoal: Int(waterGoal),
            stepsGoal: Int(stepsGoal)
        )
    }
}

/// This struct is used as an overlay to always display the fresh value from CoreData
struct UserDisplay: Identifiable, Equatable {
    let id: UUID
    let firstName: String
    let lastName: String
    let calorieGoal: Int
    let sleepGoal: Int
    let waterGoal: Int
    let stepsGoal: Int

    var fullName: String { "\(firstName) \(lastName)" }

    var calorieGoalFormatted: String { "\(calorieGoal) kcal" }

    var sleepGoalFormatted: String {
        let hours = sleepGoal / 60
        let minutes = sleepGoal % 60
        return minutes > 0 ? "\(hours)h\(minutes)" : "\(hours)h"
    }

    var waterGoalFormatted: String { String(format: "%.1f L", Double(waterGoal) / 10) }

    var stepsGoalFormatted: String { stepsGoal.formatSteps }
}

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
    @NSManaged public var calorieGoal: Int16
    @NSManaged public var email: String
    @NSManaged public var firstName: String
    @NSManaged public var hashPassword: String
    @NSManaged public var id: UUID
    @NSManaged public var isLogged: Bool
    @NSManaged public var lastName: String
    @NSManaged public var salt: UUID
    @NSManaged public var sleepGoal: Int16
    @NSManaged public var waterGoal: Int16

    @NSManaged public var exercices: Set<Exercice>?
    @NSManaged public var sleepCycles: Set<SleepCycle>?
}

extension User {
    /// in User goals will use this format to always use Int:
    /// calorieGoal - unit: kCal, default value: 2000 kCal
    /// sleeepGoal - unit: minute, default value: 480 minutes (8hours)
    /// waterGoal - unit: deciliter, default valut: 25 dl (2,5 liter)

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
}

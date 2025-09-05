//
//  Meal.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//
//

import Foundation
import CoreData

@objc(Meal)
public class Meal: NSManagedObject {
    @NSManaged public var date: Date
    @NSManaged public var type: String
    @NSManaged public var mealContents: Set<MealContent>?
    @NSManaged public var user: User
}

extension Meal {
    /// Used to convert the String from coreData into MealType enum
    var mealTypeEnum: MealType {
        get { MealType(rawValue: type) ?? .snack}
        set { type = newValue.rawValue}
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }
}

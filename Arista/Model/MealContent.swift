//
//  MealContent.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//
//

import Foundation
import CoreData

@objc(MealContent)
public class MealContent: NSManagedObject {
    @NSManaged public var quantity: Int16
    @NSManaged public var aliment: Aliment
    @NSManaged public var meal: Meal
}

extension MealContent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealContent> {
        return NSFetchRequest<MealContent>(entityName: "MealContent")
    }
}

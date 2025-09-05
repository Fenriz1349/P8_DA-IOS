//
//  Aliment+CoreDataClass.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//
//

import Foundation
import CoreData

@objc(Aliment)
public class Aliment: NSManagedObject {
    @NSManaged public var calPerPortion: Int16
    @NSManaged public var isSolid: Bool
    @NSManaged public var name: String
    @NSManaged public var mealContents: Set<MealContent>?
}

extension Aliment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aliment> {
        return NSFetchRequest<Aliment>(entityName: "Aliment")
    }
}

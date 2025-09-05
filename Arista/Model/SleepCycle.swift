//
//  SleepCycle.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//
//

import Foundation
import CoreData

@objc(SleepCycle)
public class SleepCycle: NSManagedObject {
    @NSManaged public var dateBegging: Int16
    @NSManaged public var dateEnding: Date
    @NSManaged public var quality: Int16
    @NSManaged public var user: User
}

extension SleepCycle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepCycle> {
        return NSFetchRequest<SleepCycle>(entityName: "SleepCycle")
    }
}

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
public class SleepCycle: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var dateStart: Date
    @NSManaged public var dateEnding: Date?
    @NSManaged public var quality: Int16
    @NSManaged public var user: User
}

extension SleepCycle {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepCycle> {
        return NSFetchRequest<SleepCycle>(entityName: "SleepCycle")
    }

    static func mapToDisplay(from cycles: [SleepCycle]) -> [SleepCycleDisplay] {
        cycles.map { $0.toDisplay}
    }

    var toDisplay: SleepCycleDisplay {
        SleepCycleDisplay(
            id: id,
            dateStart: dateStart,
            dateEnding: dateEnding,
            quality: Int(quality)
        )
    }
}

struct SleepCycleDisplay: Identifiable, Equatable {
    let id: UUID
    let dateStart: Date
    let dateEnding: Date?
    let quality: Int

    var isCompleted: Bool { return dateEnding != nil }

    var isActive: Bool { return dateEnding == nil }

    var sleepQuality: Grade { return Grade(quality) }

    var qualityDescription: String { return sleepQuality.description }
}

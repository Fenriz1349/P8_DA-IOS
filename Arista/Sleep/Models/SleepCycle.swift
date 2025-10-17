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

    var isCompleted: Bool { return dateEnding != nil }

    var isActive: Bool { return dateEnding == nil }

    var sleepQuality: SleepQuality {
        return SleepQuality(from: quality)
    }

    var qualityDescription: String {
        return sleepQuality.description
    }

    static func mapToDisplay(from cycles: [SleepCycle]) -> [SleepCycleDisplay] {
        cycles.map {
            SleepCycleDisplay(
                id: $0.id,
                dateStart: $0.dateStart,
                dateEnding: $0.dateEnding,
                quality: $0.quality
            )
        }
    }

    var toDisplay: SleepCycleDisplay {
        SleepCycleDisplay(
            id: self.id,
            dateStart: self.dateStart,
            dateEnding: self.dateEnding,
            quality: self.quality
        )
    }
}

struct SleepCycleDisplay: Identifiable, Equatable {
    let id: UUID
    let dateStart: Date
    let dateEnding: Date?
    let quality: Int16

    var sleepQuality: SleepQuality {
        return SleepQuality(from: quality)
    }

    var qualityDescription: String {
        return sleepQuality.description
    }
}

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
    /// Creates and returns a fetch request for SleepCycle entities
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepCycle> {
        return NSFetchRequest<SleepCycle>(entityName: "SleepCycle")
    }

    /// Converts an array of SleepCycle entities to an array of SleepCycleDisplay view models
    /// - Parameter cycles: Array of SleepCycle entities to convert
    /// - Returns: Array of SleepCycleDisplay instances
    static func mapToDisplay(from cycles: [SleepCycle]) -> [SleepCycleDisplay] {
        cycles.map { $0.toDisplay}
    }

    /// Converts the SleepCycle entity to a SleepCycleDisplay view model
    /// - Returns: SleepCycleDisplay instance with formatted sleep cycle data
    var toDisplay: SleepCycleDisplay {
        SleepCycleDisplay(
            id: id,
            dateStart: dateStart,
            dateEnding: dateEnding,
            quality: Int(quality)
        )
    }
}

/// This struct is used as an overlay to always display the fresh value from CoreData
struct SleepCycleDisplay: Identifiable, Equatable {
    let id: UUID
    let dateStart: Date
    let dateEnding: Date?
    let quality: Int

    /// Returns true if the sleep cycle has an end date
    var isCompleted: Bool { return dateEnding != nil }

    /// Returns true if the sleep cycle is currently active (no end date)
    var isActive: Bool { return dateEnding == nil }

    /// Returns the sleep quality as a Grade
    var sleepQuality: Grade { return Grade(quality) }

    /// Returns the localized quality description (e.g., "Good", "Excellent")
    var qualityDescription: String { return sleepQuality.description }
}

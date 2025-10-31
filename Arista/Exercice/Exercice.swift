//
//  Exercice.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//
//

import Foundation
import CoreData

@objc(Exercice)
public class Exercice: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var duration: Int16
    @NSManaged public var intensity: Int16
    @NSManaged public var type: String
    @NSManaged public var user: User
}

extension Exercice {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercice> {
        return NSFetchRequest<Exercice>(entityName: "Exercice")
    }

    /// Converts the string type from CoreData into an ExerciceType enum
    var typeEnum: ExerciceType {
        get { ExerciceType(rawValue: type) ?? .other}
        set { type = newValue.rawValue}
    }

    /// Converts the Exercice entity to an ExerciceDisplay view model
    /// - Returns: ExerciceDisplay instance with formatted exercise data
    var toDisplay: ExerciceDisplay {
        ExerciceDisplay(
            id: id,
            date: date,
            duration: Int(duration),
            intensity: Int(intensity),
            type: typeEnum
        )
    }

    /// Converts an array of Exercice entities to an array of ExerciceDisplay view models
    /// - Parameter exercices: Array of Exercice entities to convert
    /// - Returns: Array of ExerciceDisplay instances
    static func mapToDisplay(from exercices: [Exercice]) -> [ExerciceDisplay] {
        exercices.map { $0.toDisplay }
    }
}

/// This struct is used as an overlay to always display the fresh value from CoreData
struct ExerciceDisplay: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let duration: Int
    let intensity: Int
    let type: ExerciceType

    var exerciceIntensity: Grade { return Grade(intensity) }

    var intensityDescription: String { return exerciceIntensity.description }

    var caloriesBurned: Int {
        return Int(Double(duration) * Double(intensity) * type.calorieFactor)
    }
}

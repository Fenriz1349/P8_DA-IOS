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

    /// Used to convert the String from coreData into ExerciceType enum
    var typeEnum: ExerciceType {
        get { ExerciceType(rawValue: type) ?? .other}
        set { type = newValue.rawValue}
    }

    var toDisplay: ExerciceDisplay {
        ExerciceDisplay(
            id: id,
            date: date,
            duration: Int(duration),
            intensity: Int(intensity),
            type: typeEnum
        )
    }

    static func mapToDisplay(from exercices: [Exercice]) -> [ExerciceDisplay] {
        exercices.map { $0.toDisplay }
    }
}

struct ExerciceDisplay: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let duration: Int
    let intensity: Int
    let type: ExerciceType

    var exerciceIntensity: Grade { return Grade(intensity) }

    var intensityDescription: String { return exerciceIntensity.description }
    
    var caloriesBurned: Int {
        let base = Double(duration) * Double(intensity) * type.calorieFactor
        return Int(base / 10)
    }

}

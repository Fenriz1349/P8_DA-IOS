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
    @NSManaged public var date: Date
    @NSManaged public var duration: Int16
    @NSManaged public var intensity: Int16
    @NSManaged public var type: String
    @NSManaged public var user: User
}

extension Exercice {
    /// Used to convert the String from coreData into ExerciceType enum
    var typeEnum: ExerciceType {
        get { ExerciceType(rawValue: type ?? "") ?? .other}
        set { type = newValue.rawValue}
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercice> {
        return NSFetchRequest<Exercice>(entityName: "Exercice")
    }
}

//
//  Meal+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 01/08/2025.
//

import Foundation

extension Meal {

    /// Used to convert the String from coreData into MealType enum
    var mealTypeEnum: MealType {
        get { MealType(rawValue: type ?? "") ?? .snack}
        set { type = newValue.rawValue}
    }
}

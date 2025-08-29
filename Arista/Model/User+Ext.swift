//
//  User+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 01/08/2025.
//

import Foundation

extension User {
    /// in User goals will use this format to always use Int:
    /// calorieGoal - unit: kCal, default value: 2000 kCal
    /// sleeepGoal - unit: minute, default value: 480 minutes (8hours)
    /// waterGoal - unit: deciliter, default valut: 25 dl (2,5 liter)

    /// Used to convert the String from coreData into Gender enum
    var genderEnum: Gender {
        get { Gender(rawValue: gender ?? "") ?? .other}
        set { gender = newValue.rawValue}
    }

    /// CoreData don't handle nil value for Int64
    /// So O will be used as undefined value
    var hasWeight: Bool { weight > 0 }

    var hasSize: Bool { size > 0 }

    /// CoreData don't handle natively non optionnal String, so we use those var to simplify display
    var login: String { return email ?? "" }

    var firstNameSafe: String { return firstName ?? "" }

    var lastNameSafe: String { return lastName ?? "" }
}

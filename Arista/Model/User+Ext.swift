//
//  User+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 01/08/2025.
//

import Foundation

extension User {
    
    /// Used to convert the String from coreData into Gender enum
    var genderEnum: Gender {
        get { Gender(rawValue: gender ?? "") ?? .other}
        set { gender = newValue.rawValue}
    }
    
}

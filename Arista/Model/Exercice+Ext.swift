//
//  Exercice+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 01/08/2025.
//

import Foundation

extension Exercice {

    /// Used to convert the String from coreData into ExerciceType enum
    var typeEnum: ExerciceType {
        get { ExerciceType(rawValue: type ?? "") ?? .other}
        set { type = newValue.rawValue}
    }
}

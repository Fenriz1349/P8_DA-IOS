//
//  String+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 29/10/2025.
//

import Foundation

extension String {
    /// Returns the localized version of the string
    /// - Returns: Localized string from the Localizable.xcstrings catalog
    var localized: String {
        String(localized: String.LocalizationValue(self))
    }
}

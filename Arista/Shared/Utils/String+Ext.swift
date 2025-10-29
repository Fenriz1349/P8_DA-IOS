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
    
    /// Returns the localized version of the string with interpolated parameters
    /// - Parameter arguments: Values to interpolate in the localized string
    /// - Returns: Localized string with parameters replaced
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

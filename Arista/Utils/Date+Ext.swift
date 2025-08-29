//
//  Date+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation

extension Date {
    /// Get only year month and day of a date
    var ymdComponents: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: self)
    }

    func isSameDay(as other: Date) -> Bool {
        let selfComponents = self.ymdComponents
        let otherComponents = other.ymdComponents
        return selfComponents.year == otherComponents.year &&
               selfComponents.month == otherComponents.month &&
               selfComponents.day == otherComponents.day
    }
}

//
//  DayCalories.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import Foundation

struct DayCalories: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int

    /// Returns the abbreviated day name (e.g., "Lun", "Mar")
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }

    /// Returns the date in short format (e.g., "01/12")
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}

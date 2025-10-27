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

    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}

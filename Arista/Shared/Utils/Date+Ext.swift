//
//  Date+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation

enum DateValidationError: Error, LocalizedError {
    case endDateBeforeStartDate

    var errorDescription: String? {
        switch self {
        case .endDateBeforeStartDate:
            return "L'heure de fin doit être après l'heure de début."
        }
    }
}

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

    func duration(to endDate: Date) -> TimeInterval {
        return endDate.timeIntervalSince(self)
    }

    static func validateInterval(from startDate: Date, to endDate: Date) throws {
        guard endDate > startDate else {
            throw DateValidationError.endDateBeforeStartDate
        }
    }

    func formattedInterval(to endDate: Date) -> String {
        let duration = duration(to: endDate)
        let totalHours = Int(duration) / 3600
        let totalMinutes = (Int(duration) % 3600) / 60

        switch (totalHours, totalMinutes) {
        case (0, let minutes): return "\(minutes)min"
        case (let hours, 0): return "\(hours)h"
        default: return "\(totalHours)h \(totalMinutes)min"
        }
    }


    /// Format hour only (ex: "14:30")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Format date only (ex: "mardi 21 octobre 2025")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: self)
    }

    /// Format date + hour (ex: "15 oct. 2024 à 14:30")
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

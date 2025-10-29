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
        case .endDateBeforeStartDate: return "error.date.endDateBeforeStartDate".localized
        }
    }
}

extension Date {
    /// Returns date components containing only year, month and day
    var ymdComponents: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: self)
    }

    /// Checks if the date is on the same day as another date
    /// - Parameter other: The date to compare with
    /// - Returns: true if both dates are on the same day, false otherwise
    func isSameDay(as other: Date) -> Bool {
        let selfComponents = self.ymdComponents
        let otherComponents = other.ymdComponents
        return selfComponents.year == otherComponents.year &&
               selfComponents.month == otherComponents.month &&
        selfComponents.day == otherComponents.day
    }

    /// Calculates the time interval duration between this date and an end date
    /// - Parameter endDate: The end date of the interval
    /// - Returns: The duration in seconds as a TimeInterval
    func duration(to endDate: Date) -> TimeInterval {
        return endDate.timeIntervalSince(self)
    }

    /// Validates that an end date is after a start date
    /// - Parameters:
    ///   - startDate: The start date of the interval
    ///   - endDate: The end date of the interval
    /// - Throws: DateValidationError.endDateBeforeStartDate if endDate is before or equal to startDate
    static func validateInterval(from startDate: Date, to endDate: Date) throws {
        guard endDate > startDate else {
            throw DateValidationError.endDateBeforeStartDate
        }
    }

    /// Formats the duration between this date and an end date as a human-readable string
    /// - Parameter endDate: The end date of the interval
    /// - Returns: Formatted string (e.g., "2h 30min", "45min", "3h")
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

    /// Returns the formatted time in short style (e.g., "14:30")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns the formatted date in long style using the current locale (e.g., "mardi 21 octobre 2025")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: self)
    }

    /// Returns the formatted date and time in medium/short style (e.g., "15 oct. 2024 à 14:30")
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

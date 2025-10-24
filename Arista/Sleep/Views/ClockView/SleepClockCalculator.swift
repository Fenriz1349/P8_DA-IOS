//
//  SleepClockCalculator.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import Foundation

final class SleepClockCalculator {
    private static let maxDuration: TimeInterval = 12 * 3600

    /// Converts an hour (0–23) into an angle for a 12-hour dial.
    /// 0h = top (0°), 3h = right (90°), 6h = bottom (180°), 9h = left (270°)
    static func angleForHour(_ hour: Int) -> Double {
        let adjustedHour = Double(hour % 12)
        return adjustedHour / 12 * 360
    }

    /// Converts a full Date into an angle for the 12-hour dial.
    /// Each hour = 30°, each minute = 0.5°.
    /// 0h is at the top (0° - no offset needed since we rotate the arc)
    static func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date) % 12
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = Double(hour * 60 + minute)
        return (totalMinutes / (12 * 60)) * 360 - 90
    }

    /// Determines the 12 consecutive hours to display on the clock.
    /// Starts from the beginning of the current or active sleep cycle.
    /// If no cycle, uses the current time as reference.
    static func hoursToDisplay(for cycle: SleepCycleDisplay?) -> [Int] {
        let calendar = Calendar.current
        let now = Date()

        guard let cycle = cycle else {
            let centerHour = calendar.component(.hour, from: now)
            let startHour = (centerHour - 6 + 24) % 24
            return (0..<12).map { (startHour + $0) % 24 }
        }

        let startHour = calendar.component(.hour, from: cycle.dateStart)
        return (0..<12).map { (startHour + $0) % 24 }
    }

    /// Calculates the sleep duration to display, limited to 12h maximum.
    /// This ensures that any cycle longer than 12h fills the full circle.
    static func displayedDuration(for cycle: SleepCycleDisplay) -> TimeInterval {
        let end = cycle.dateEnding ?? Date()
        let duration = end.timeIntervalSince(cycle.dateStart)

        let adjustedDuration = duration < 0 ? duration + (24 * 3600) : duration

        return min(adjustedDuration, maxDuration)
    }
}

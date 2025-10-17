//
//  SleepClockCalculator.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import Foundation

final class SleepClockCalculator {
    /// Converts an hour (0-23) to angle (0-360°)
    /// 0h (midnight) = 0°, 6h = 90°, 12h (noon) = 180°, 18h = 270°
    static func angleForHour(_ hour: Int) -> Double {
        return Double(hour) * 30 // 360° / 12h = 30° per hour
    }

    /// Converts a Date to angle for 24h clock (0-360°)
    /// Midnight = 0°, 6h = 90°, 12h = 180°, 18h = 270°
    static func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        let hourAngle = Double(hour % 12) * 30 // 30° per hour
        let minuteAngle = Double(minute) * 0.5 // 0.5° per minute (30°/60min)

        return hourAngle + minuteAngle
    }

    /// Determine which 12 hours to display based on sleep cycle or current time
    /// Returns an array of 12 consecutive hours (0-23)
    static func hoursToDisplay(for sleepCycle: SleepCycleDisplay?) -> [Int] {
        let startHour: Int

        if let cycle = sleepCycle {
            let cycleStartHour = Calendar.current.component(.hour, from: cycle.dateStart)

            // Night sleep typically starts between 18h-23h or 0h-5h
            // Day nap typically starts between 6h-17h
            let isNightSleep = (cycleStartHour >= 18) || (cycleStartHour < 6)

            startHour = isNightSleep ? 18 : 6
        } else {
            let currentHour = Calendar.current.component(.hour, from: Date())

            startHour = (currentHour >= 18 || currentHour < 6) ? 18 : 6
        }

        return (0..<12).map { (startHour + $0) % 24 }
    }
}

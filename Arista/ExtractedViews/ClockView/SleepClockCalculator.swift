//
//  SleepClockCalculator.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import Foundation

final class SleepClockCalculator {
    #warning("passer à 12h")
    /// Converts an hour (0-23) to angle (0-360°)
    /// 0h (midnight) = 0°, 6h = 90°, 12h (noon) = 180°, 18h = 270°
    static func angleForHour(_ hour: Int) -> Double {
        return Double(hour) * 15 // 360° / 24h = 15° per hour
    }

    /// Converts a Date to angle for 24h clock (0-360°)
    /// Midnight = 0°, 6h = 90°, 12h = 180°, 18h = 270°
    static func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        let hourAngle = Double(hour) * 15 // 15° per hour
        let minuteAngle = Double(minute) * 0.25 // 0.25° per minute (15°/60min)

        return hourAngle + minuteAngle
    }
}

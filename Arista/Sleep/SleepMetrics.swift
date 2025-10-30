//
//  SleepMetrics.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

/// Represents aggregated sleep metrics for display purposes
struct SleepMetrics {
    let averageDuration: TimeInterval
    let sleepGoal: Int
    let averageQuality: Double

    /// Average sleep duration in hours
    var averageHours: Double {
        averageDuration / 3600
    }

    /// Sleep goal converted to hours
    var goalHours: Double {
        Double(sleepGoal) / 60
    }

    /// Progress towards sleep goal (0.0 to 1.0+)
    var progress: Double {
        guard goalHours > 0 else { return 0 }
        return averageHours / goalHours
    }

    /// Sleep quality grade based on average quality
    var grade: Grade {
        Grade(Int(averageQuality))
    }

    /// Icon representing the current sleep status
    var statusIcon: String {
        if progress >= 1.0 {
            return "💪"
        } else if progress >= 0.85 {
            return "😊"
        } else {
            return "😴"
        }
    }

    /// Localized text describing the current sleep status
    var statusText: String {
        if progress >= 1.0 {
            return "sleep.metrics.status.goalAchieved".localized
        } else if progress >= 0.85 {
            return "sleep.metrics.status.closeToGoal".localized
        } else {
            return "sleep.metrics.status.belowGoal".localized
        }
    }

    /// Color representing the progress status
    var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.85 {
            return .orange
        } else {
            return .red
        }
    }

    /// Formatted average duration as "Xh" or "XhY"
    var formattedAverageDuration: String {
        let hours = Int(averageHours)
        let minutes = Int((averageDuration.truncatingRemainder(dividingBy: 3600)) / 60)
        return minutes > 0 ? "\(hours)h\(minutes)" : "\(hours)h"
    }

    /// Formatted sleep goal as "Xh" or "XhY"
    var formattedGoal: String {
        let hours = sleepGoal / 60
        let minutes = sleepGoal % 60
        return minutes > 0 ? "\(hours)h\(minutes)" : "\(hours)h"
    }
}

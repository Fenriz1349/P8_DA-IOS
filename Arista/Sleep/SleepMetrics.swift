//
//  SleepMetrics.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

struct SleepMetrics {
    let averageDuration: TimeInterval
    let sleepGoal: Int
    let averageQuality: Double

    var averageHours: Double {
        averageDuration / 3600
    }

    var goalHours: Double {
        Double(sleepGoal) / 60
    }

    var progress: Double {
        guard goalHours > 0 else { return 0 }
        return averageHours / goalHours
    }

    var grade: Grade {
        Grade(Int(averageQuality))
    }

    var statusIcon: String {
        if progress >= 1.0 {
            return "💪"
        } else if progress >= 0.85 {
            return "😊"
        } else {
            return "😴"
        }
    }

    var statusText: String {
        if progress >= 1.0 {
            return "Objectif atteint"
        } else if progress >= 0.85 {
            return "Proche de l'objectif"
        } else {
            return "En dessous de l'objectif"
        }
    }

    var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.85 {
            return .orange
        } else {
            return .red
        }
    }

    var formattedAverageDuration: String {
        let hours = Int(averageHours)
        let minutes = Int((averageDuration.truncatingRemainder(dividingBy: 3600)) / 60)
        return minutes > 0 ? "\(hours)h\(minutes)" : "\(hours)h"
    }

    var formattedGoal: String {
        let hours = sleepGoal / 60
        let minutes = sleepGoal % 60
        return minutes > 0 ? "\(hours)h\(minutes)" : "\(hours)h"
    }
}

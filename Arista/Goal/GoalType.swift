//
//  GoalType.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

enum GoalType: CaseIterable {
    case water
    case sleep
    case calories
    case steps

    var title: String {
        switch self {
        case .water: return "goal.type.water".localized
        case .sleep: return "goal.type.sleep".localized
        case .calories: return "goal.type.calories".localized
        case .steps: return "goal.type.steps".localized
        }
    }

    var color: Color {
        switch self {
        case .water: return .blue
        case .sleep: return .indigo
        case .calories: return .orange
        case .steps: return .green
        }
    }

    var iconName: String {
        switch self {
        case .water: return "drop.fill"
        case .sleep: return "moon.zzz.fill"
        case .calories: return "flame.fill"
        case .steps: return "figure.walk"
        }
    }

    var range: ClosedRange<Int> {
        switch self {
        case .water: return 0...50
        case .sleep: return 0...1440
        case .calories: return 0...4000
        case .steps: return 0...25000
        }
    }

    var step: Int {
        switch self {
        case .water: return 1
        case .sleep: return 30
        case .calories: return 100
        case .steps: return 500
        }
    }

    func formatted(_ value: Int) -> String {
        switch self {
        case .water: return value.formatWater
        case .sleep: return value.formattedInterval
        case .calories: return "\(value) kcal"
        case .steps: return value.formatSteps
        }
    }

    var sliderStep: Double {
        Double(step)
    }
}

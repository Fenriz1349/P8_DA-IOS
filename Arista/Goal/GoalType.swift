//
//  GoalType.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

enum GoalType {
    case water
    case steps

    var icon: String {
        switch self {
        case .water: return "💧"
        case .steps: return "👣"
        }
    }

    var title: String {
        switch self {
        case .water: return "Eau"
        case .steps: return "Pas"
        }
    }

    var color: Color {
        switch self {
        case .water: return .blue
        case .steps: return .green
        }
    }

    var sliderStep: Double {
        switch self {
        case .water: return 1
        case .steps: return 100
        }
    }

    func formatted(_ value: Int) -> String {
        switch self {
        case .water: return value.formatWater
        case .steps: return value.formatSteps
        }
    }
}

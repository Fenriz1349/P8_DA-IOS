//
//  ExerciceType.swift
//  Arista
//
//  Created by Julien Cotte on 31/07/2025.
//

enum ExerciceType {
    case running
    case swimming
    case cycling
    case walking
    case workout
    case football
    case basketball
    case handball
    case rugby
    case tennis
    case yoga
    case other
    
    var iconName: String {
        switch self {
        case .running: "figure.run"
        case .swimming: "figure.pool.swim"
        case .cycling: "figure.outdoor.cycle"
        case .walking: "figure.walk"
        case .workout: "figure.strengthtraining.traditional"
        case .football: "figure.outdoor.soccer"
        case .basketball: "figure.basketball"
        case .handball: "figure.handball"
        case .rugby: "figure.rugby"
        case .tennis: "figure.tennis"
        case .yoga: "figure.mind.and.body"
        case .other: "questionmark"
        }

    }
}

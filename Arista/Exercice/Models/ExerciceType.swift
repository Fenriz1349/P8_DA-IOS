//
//  ExerciceType.swift
//  Arista
//
//  Created by Julien Cotte on 31/07/2025.
//

enum ExerciceType: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case cardio, strength, yoga, pilates, running, walking
    case cycling, swimming, climbing, dance, boxing
    case crossfit, football, basketball, tennis, golf
    case rowing, skiing, surfing, hiking, stretching
    case other

    var displayName: String {
        switch self {
        case .cardio: return "Cardio"
        case .strength: return "Musculation"
        case .yoga: return "Yoga"
        case .pilates: return "Pilates"
        case .running: return "Course"
        case .walking: return "Marche"
        case .cycling: return "Vélo"
        case .swimming: return "Natation"
        case .climbing: return "Escalade"
        case .dance: return "Danse"
        case .boxing: return "Boxe"
        case .crossfit: return "CrossFit"
        case .football: return "Football"
        case .basketball: return "Basket"
        case .tennis: return "Tennis"
        case .golf: return "Golf"
        case .rowing: return "Aviron"
        case .skiing: return "Ski"
        case .surfing: return "Surf"
        case .hiking: return "Randonnée"
        case .stretching: return "Étirements"
        case .other: return "Autre"
        }
    }

    var iconName: String {
        switch self {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.mind.and.body"
        case .pilates: return "figure.cooldown"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .climbing: return "figure.climbing"
        case .dance: return "music.note"
        case .boxing: return "figure.boxing"
        case .crossfit: return "flame.fill"
        case .football: return "soccerball"
        case .basketball: return "basketball.fill"
        case .tennis: return "tennisball"
        case .golf: return "flag.checkered"
        case .rowing: return "figure.rower"
        case .skiing: return "figure.skiing.downhill"
        case .surfing: return "figure.surfing"
        case .hiking: return "figure.hiking"
        case .stretching: return "figure.cooldown"
        case .other: return "ellipsis"
        }
    }

    var calorieFactor: Double {
        switch self {
        case .running, .cycling, .swimming: return 1.5
        case .football, .basketball, .boxing: return 1.3
        case .yoga, .pilates, .stretching: return 0.6
        case .strength, .crossfit: return 1.1
        case .walking, .hiking: return 0.8
        default: return 1.0
        }
    }

}


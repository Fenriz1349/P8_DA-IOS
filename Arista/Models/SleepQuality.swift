//
//  SleepQuality.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import SwiftUI

enum SleepQuality: Int16, CaseIterable {
    case notRated
    case poor
    case fair
    case good
    case excellent

    var description: String {
        switch self {
        case .notRated:
            return "Non évaluée"
        case .poor:
            return "Mauvaise"
        case .fair:
            return "Correcte"
        case .good:
            return "Bonne"
        case .excellent:
            return "Excellente"
        }
    }

    var qualityColor: Color {
        switch self {
        case .notRated:
            return .gray
        case .poor:
            return .red
        case .fair:
            return .orange
        case .good:
            return .green
        case .excellent:
            return .blue
        }
    }

    init(from value: Int16) {
        switch value {
        case 0:
            self = .notRated
        case 1...3:
            self = .poor
        case 4...6:
            self = .fair
        case 7...8:
            self = .good
        case 9...10:
            self = .excellent
        default:
            self = .notRated
        }
    }
}

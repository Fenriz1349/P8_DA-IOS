//
//  SleepQuality.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import SwiftUI

struct Grade: Equatable {
    let value: Int

    var description: String {
        switch value {
        case 1...3: return "grade.poor".localized
        case 4...6: return "grade.fair".localized
        case 7...8: return "grade.good".localized
        case 9...10: return "grade.excellent".localized
        default: return "grade.ungraded".localized
        }
    }

    var color: Color {
        switch value {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...8: return .green
        case 9...10: return .blue
        default: return .gray
        }
    }

    init(_ value: Int) {
        self.value = max(0, min(value, 10))
    }
}

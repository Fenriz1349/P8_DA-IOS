//
//  ToastyType.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import SwiftUI

enum ToastyType {
    case error

    var color: Color {
        switch self {
        case .error: return .red
        }
    }

    var iconName: String {
        switch self {
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    var timeout: TimeInterval {
        return 0
    }
}

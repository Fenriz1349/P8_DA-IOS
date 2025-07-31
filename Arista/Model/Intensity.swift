//
//  Intensity.swift
//  Arista
//
//  Created by Julien Cotte on 31/07/2025.
//

import SwiftUI

enum Intensity : String, CaseIterable {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"

    var color: Color {
        switch self {
        case .zero, .one, .two, .three :.green
        case .four, .five, .six: .yellow
        case .seven, .eight, .nine, .ten: .red
        }
    }
}

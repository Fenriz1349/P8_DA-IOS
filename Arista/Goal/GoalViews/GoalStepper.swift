//
//  GoalStepper.swift
//  Arista
//
//  Created by Julien Cotte on 27/10/2025.
//

import SwiftUI

struct GoalStepper: View {
    let type: GoalType
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(type.icon)
            Text(type.title)
                .foregroundColor(type.color)
            Spacer()
            Stepper(
                value: $value,
                in: type.range,
                step: type.step
            ) {
                Text(type.formatted(value))
                    .foregroundColor(type.color)
                    .font(.headline)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    GoalStepper(type: .calories, value: .constant(100))
}

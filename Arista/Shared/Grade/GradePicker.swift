//
//  SleepQualityPicker.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct GradePicker: View {
    let title: String
    @Binding var quality: Int

    var body: some View {
        let grade = Grade(quality)

        VStack(spacing: 8) {
            HStack {
                Text(title)
                Text(grade.value.description)
                    .foregroundColor(grade.color)
                Text(grade.description)
                    .foregroundColor(grade.color)
            }
            .font(.headline)

            Slider(value: Binding(
                get: { Double(quality) },
                set: { quality = Int($0) }
            ), in: 0...10, step: 1)
            .tint(.blue)
        }
        .padding()
    }
}

#Preview {
    GradePicker(title: "Qualité", quality: .constant(7))
}

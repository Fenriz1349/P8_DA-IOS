//
//  SleepQualityPicker.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct SleepQualityPicker: View {
    @Binding var quality: Int16

    var body: some View {
        HStack {
            Text("Qualité du sommeil (optionnel)")
                .font(.headline)

            Spacer()

            Picker("Qualité", selection: $quality) {
                Text("Non évaluée").tag(Int16(0))
                ForEach(1...10, id: \.self) { value in
                    Text("\(value)").tag(Int16(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 160, height: 60)
            .clipped()
        }
    }
}

#Preview {
    SleepQualityPicker(quality: .constant(7))
}

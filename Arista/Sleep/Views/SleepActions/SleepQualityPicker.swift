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
        VStack(spacing: 8) {
            HStack {
                Text("Qualité")
                    .font(.headline)
                Text(quality == 0 ? "Non évaluée" : "\(quality)/10")
                    .font(.headline)
                    .foregroundColor(SleepQuality(from: quality).qualityColor)
            }
            
            Slider(
                value: Binding(
                    get: { Double(quality) },
                    set: { quality = Int16($0) }
                ),
                in: 0...10,
                step: 1
            )
            .tint(.blue)
        }
    }
}

#Preview {
    SleepQualityPicker(quality: .constant(7))
}

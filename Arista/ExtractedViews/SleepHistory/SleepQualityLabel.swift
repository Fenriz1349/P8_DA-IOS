//
//  SleepQualityLabel.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct SleepQualityLabel: View {
    let quality: SleepQuality

    var body: some View {
        ZStack {
            Circle()
                .fill(quality.qualityColor)
                .frame(width: 32, height: 32)

            Text("\(quality.rawValue)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SleepQualityLabel(quality: .good)
}

//
//  SleepQualityLabel.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct SleepQualityLabel: View {
    let quality: Int16
    private var sleepQuality: SleepQuality { SleepQuality(from: quality) }

    var body: some View {

        ZStack {
            Circle()
                .fill(sleepQuality.qualityColor)
                .frame(width: 32, height: 32)

            Text("\(quality)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SleepQualityLabel(quality: 5)
}

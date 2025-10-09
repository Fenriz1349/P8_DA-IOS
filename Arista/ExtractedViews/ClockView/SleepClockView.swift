//
//  SleepClockView.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import SwiftUI

struct SleepClockView: View {
    let sleepCycle: SleepCycle?
    var size: CGFloat = 250

    private let borderWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // Clock background
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: size, height: size)

            // Double border
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: borderWidth)
                .frame(width: size, height: size)

            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)

            // Sleep cycle arc (if exists)
            if let cycle = sleepCycle {
                SleepArcView(cycle: cycle, size: size)
            }

            HourTextView(size: size)
            CurrentTimeIndicator(size: size)
        }
    }
}

#Preview("Horloge - No cycle") {
    SleepClockView(sleepCycle: nil)
        .padding()
}

#Preview("Horloge - Full Night") {
    SleepClockView(sleepCycle: PreviewDataProvider.completedSleepCycle)
        .padding()
}

#Preview("Horloge - Nap") {
    SleepClockView(sleepCycle: PreviewDataProvider.napCycle)
        .padding()
}

#Preview("Horloge - Active Cycle") {
    SleepClockView(sleepCycle: PreviewDataProvider.activeSleepCycle)
        .padding()
}

//
//  SleepArcView.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct SleepArcView: View {
    let cycle: SleepCycleDisplay
    let size: CGFloat

    private var color: Color {
        cycle.dateEnding == nil ? .orange : .blue
    }

    var body: some View {
        let startAngle = SleepClockCalculator.angleForTime(cycle.dateStart)
        let duration = SleepClockCalculator.displayedDuration(for: cycle)

        let durationAngle = (duration / (12 * 3600)) * 360

        Circle()
            .trim(from: 0, to: durationAngle / 360)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(startAngle))
    }
}

#Preview("Arc court") {
    SleepArcView(
        cycle: PreviewSleepDataProvider.napCycle,
        size: 250
    )
}

#Preview("Arc 12h+") {
    let longCycle = SleepCycleDisplay(
        id: UUID(),
        dateStart: Date().addingTimeInterval(-14 * 3600),
        dateEnding: Date(),
        quality: 7
    )
    return SleepArcView(cycle: longCycle, size: 250)
}

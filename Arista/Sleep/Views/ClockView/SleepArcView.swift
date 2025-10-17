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
        let endAngle = SleepClockCalculator.angleForTime(cycle.dateEnding ?? Date())

        if endAngle < startAngle {
            // Cycle crosses midnight - draw 2 arcs

            // Arc 1: from start to midnight (360°)
            sleepArc(from: startAngle, to: 360)

            // Arc 2: from midnight (0°) to end
            sleepArc(from: 0, to: endAngle)
        } else {
            // Normal cycle within same day
            sleepArc(from: startAngle, to: endAngle)
        }
    }

    private func sleepArc(from startAngle: Double, to endAngle: Double) -> some View {
        Circle()
            .trim(
                from: startAngle / 360,
                to: endAngle / 360
            )
            .stroke(
                color,
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(-90)) // Midnight at top
    }
}

#Preview {
    SleepArcView(cycle: PreviewSleepDataProvider.activeSleepCycle, size: 250)
}

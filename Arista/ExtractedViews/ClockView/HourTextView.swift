//
//  HourTextView.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct HourTextView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<24, id: \.self) { hour in
                hourText(for: hour)
            }
        }
    }

    private func hourText(for hour: Int) -> some View {
        let angle = SleepClockCalculator.angleForHour(hour)
        let radius = size / 2 - 24

        // Convert angle to coordinates
        let radians = (angle - 90) * .pi / 180 // -90 to have midnight at top
        let xPos = cos(radians) * radius
        let yPos = sin(radians) * radius

        // Primary hours (0, 6, 12, 18) in bold
        let isPrimaryHour = hour % 6 == 0

        return Text(hour == 0 ? "00" : "\(hour)")
            .font(.system(size: isPrimaryHour ? 18 : 14, weight: isPrimaryHour ? .bold : .regular))
            .foregroundColor(isPrimaryHour ? .primary : .secondary)
            .offset(x: xPos, y: yPos)
    }
}

#Preview {
    HourTextView(size: 250)
}

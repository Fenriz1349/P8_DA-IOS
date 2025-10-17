//
//  currentTimeIndicator.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct CurrentTimeIndicator: View {
    let size: CGFloat

    var body: some View {
        let angle = SleepClockCalculator.angleForTime(Date())
        let length = size / 2 - 45

        return Path { path in
            path.move(to: CGPoint(x: size / 2, y: size / 2))

            let radians = (angle - 90) * .pi / 180
            let endX = size / 2 + cos(radians) * length
            let endY = size / 2 + sin(radians) * length

            path.addLine(to: CGPoint(x: endX, y: endY))

            let arrowSize: CGFloat = 8
            let arrowAngle1 = radians + .pi * 0.85
            let arrowAngle2 = radians - .pi * 0.85

            let arrow1X = endX + cos(arrowAngle1) * arrowSize
            let arrow1Y = endY + sin(arrowAngle1) * arrowSize

            let arrow2X = endX + cos(arrowAngle2) * arrowSize
            let arrow2Y = endY + sin(arrowAngle2) * arrowSize

            path.move(to: CGPoint(x: arrow1X, y: arrow1Y))
            path.addLine(to: CGPoint(x: endX, y: endY))
            path.addLine(to: CGPoint(x: arrow2X, y: arrow2Y))
        }
        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        .frame(width: size, height: size)
    }
}

#Preview {
    CurrentTimeIndicator(size: 250)
}

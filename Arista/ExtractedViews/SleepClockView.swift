//
//  SleepClockView.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import SwiftUI

struct SleepClockView: View {
    let sleepCycle: SleepCycle?

    private let clockSize: CGFloat = 280
    private let borderWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // Clock background
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: clockSize, height: clockSize)

            // Double border
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: borderWidth)
                .frame(width: clockSize, height: clockSize)

            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .frame(width: clockSize - borderWidth * 2, height: clockSize - borderWidth * 2)

            // Sleep cycle arc (if exists and completed)
            if let cycle = sleepCycle, let endDate = cycle.dateEnding {
                sleepArcView(from: cycle.dateStart, to: endDate)
            }

            // Hour markers (0-23)
            hourMarkers
        }
    }

    // MARK: - Sleep Arc
    @ViewBuilder
    private func sleepArcView(from startDate: Date, to endDate: Date) -> some View {
        let startAngle = angleForTime(startDate)
        let endAngle = angleForTime(endDate)

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
                Color.blue,
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .frame(width: clockSize - 30, height: clockSize - 30)
            .rotationEffect(.degrees(-90)) // Midnight at top
    }

    // MARK: - Hour Markers
    private var hourMarkers: some View {
        ZStack {
            ForEach(0..<24, id: \.self) { hour in
                hourText(for: hour)
            }
        }
    }

    private func hourText(for hour: Int) -> some View {
        let angle = angleForHour(hour)
        let radius = clockSize / 2 - 35

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

    // MARK: - Angle Calculations

    /// Converts an hour (0-23) to angle (0-360°)
    /// 0h (midnight) = 0°, 6h = 90°, 12h (noon) = 180°, 18h = 270°
    private func angleForHour(_ hour: Int) -> Double {
        return Double(hour) * 15 // 360° / 24h = 15° per hour
    }

    /// Converts a Date to angle for 24h clock (0-360°)
    /// Midnight = 0°, 6h = 90°, 12h = 180°, 18h = 270°
    private func angleForTime(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        let hourAngle = Double(hour) * 15 // 15° per hour
        let minuteAngle = Double(minute) * 0.25 // 0.25° per minute (15°/60min)

        return hourAngle + minuteAngle
    }
}

#Preview {
    VStack(spacing: 40) {
        // No Cycle
        VStack {
            Text("No Cycle")
                .font(.caption)
            SleepClockView(sleepCycle: nil)
        }

        // With normal cycle (22h → 6h)
        VStack {
            Text("Cycle 22h → 6h")
                .font(.caption)
            SleepClockView(sleepCycle: {
                let context = PreviewDataProvider.PreviewContext
                let cycle = SleepCycle(context: context)

                var components = DateComponents()
                components.hour = 22
                components.minute = 30
                cycle.dateStart = Calendar.current.date(from: components) ?? Date()

                components.hour = 6
                components.minute = 45
                cycle.dateEnding = Calendar.current.date(from: components)?.addingTimeInterval(86400)

                return cycle
            }())
        }

        // With one day cycle (14h → 15h30)
        VStack {
            Text("Rest 14h → 15h30")
                .font(.caption)
            SleepClockView(sleepCycle: {
                let context = PreviewDataProvider.PreviewContext
                let cycle = SleepCycle(context: context)

                var components = DateComponents()
                components.hour = 14
                components.minute = 0
                cycle.dateStart = Calendar.current.date(from: components) ?? Date()

                components.hour = 15
                components.minute = 30
                cycle.dateEnding = Calendar.current.date(from: components)

                return cycle
            }())
        }
    }
    .padding()
}

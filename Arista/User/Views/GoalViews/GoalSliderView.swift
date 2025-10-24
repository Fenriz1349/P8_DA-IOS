//
//  GoalSliderView.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

struct GoalSliderView: View {
    let type: GoalType
    let goal: Int
    @Binding var current: Double

    private var progress: Double { current / Double(goal)}

    private var dynamicMax: Double {
        let baseGoal = Double(goal)
        let extendedLimit = max(baseGoal, current * 1.1)
        return extendedLimit
    }

    private var dynamicStep: Double {
        let baseStep = type.sliderStep

        if current > Double(goal) {
            let ratio = current / Double(goal)
            return baseStep * ratio
        }

        return baseStep
    }

    private var displayProgress: Double { min(progress, 1.0) }

    private var fillColor: Color {
        progress > 1.0 ? .green : type.color.opacity(0.3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(type.icon)
                    .font(.title2)
                Text(type.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                GoalBadge(progress: progress)
                Text(type.formatted(Int(current)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(progress >= 1.0 ? .green : type.color)
                Text("/ \(type.formatted(goal))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 40)

                RoundedRectangle(cornerRadius: 12)
                    .fill(fillColor)
                    .frame(width: CGFloat(displayProgress) * (UIScreen.main.bounds.width - 64), height: 40)
                    .animation(.spring(), value: displayProgress)

                Slider(
                    value: $current,
                    in: 0...dynamicMax,
                    step: dynamicStep
                )
                .tint(progress >= 1.0 ? .green : type.color)
                .padding(.horizontal, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        GoalSliderView(type: .water, goal: 25, current: .constant(15))

        GoalSliderView(type: .water, goal: 25, current: .constant(25))

        GoalSliderView(type: .water, goal: 25, current: .constant(30))

        GoalSliderView(type: .steps, goal: 8000, current: .constant(12000))
    }
    .background(Color(.systemGroupedBackground))
}

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

    private var progress: Double {
        current / Double(goal)
    }

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

    private var displayProgress: Double {
        min(progress, 1.0)
    }

    private var fillColor: Color {
        progress > 1.0 ? .green : type.color.opacity(0.3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: type.iconName)
                    .font(.title3)
                    .foregroundColor(type.color)
                Text(type.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(type.formatted(Int(current)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(progress >= 1.0 ? .green : type.color)
                Text("/")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    + Text(" \(type.formatted(goal))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                GoalBadge(progress: progress)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 32)

                RoundedRectangle(cornerRadius: 10)
                    .fill(fillColor)
                    .frame(width: CGFloat(displayProgress) * (UIScreen.main.bounds.width - 64), height: 32)
                    .animation(.spring(), value: displayProgress)

                Slider(
                    value: $current,
                    in: 0...dynamicMax,
                    step: dynamicStep
                )
                .tint(progress >= 1.0 ? .green : type.color)
                .padding(.horizontal, 6)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
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

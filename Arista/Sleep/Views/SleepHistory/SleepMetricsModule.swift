//
//  SleepMetricsModule.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

struct SleepMetricsModule: View {
    let metrics: SleepMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("sleep.metrics.title".localized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "moon.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text("sleep.metrics.averageDuration".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(metrics.formattedAverageDuration)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Text("/ \(metrics.formattedGoal)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    Text(metrics.statusIcon)
                        .font(.caption)
                    Text(metrics.statusText)
                        .font(.caption2)
                        .foregroundColor(metrics.progressColor)
                }

                VStack(alignment: .center, spacing: 4) {
                    Text("Qualité moyenne")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    GradeLabel(grade: metrics.grade)

                    Text(metrics.grade.description)
                        .font(.caption2)
                        .foregroundColor(metrics.grade.color)
                }
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 8)
                    .fill(metrics.progressColor)
                    .frame(width: CGFloat(min(metrics.progress, 1.0)) * (UIScreen.main.bounds.width - 80), height: 8)
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
        SleepMetricsModule(
            metrics: SleepMetrics(
                averageDuration: 7.5 * 3600,
                sleepGoal: 480,
                averageQuality: 7.8
            )
        )

        SleepMetricsModule(
            metrics: SleepMetrics(
                averageDuration: 8.2 * 3600,
                sleepGoal: 480,
                averageQuality: 9.2
            )
        )

        SleepMetricsModule(
            metrics: SleepMetrics(
                averageDuration: 6 * 3600,
                sleepGoal: 480,
                averageQuality: 4.5
            )
        )
    }
    .background(Color(.systemGroupedBackground))
}

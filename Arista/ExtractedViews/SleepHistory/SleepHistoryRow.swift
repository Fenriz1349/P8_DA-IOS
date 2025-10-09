//
//  SleepHistoryRow.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct SleepHistoryRow: View {
    let cycle: SleepCycle

    var body: some View {
        HStack(spacing: 12) {
            SleepQualityLabel(quality: cycle.sleepQuality)

            // Sleep info
            VStack(alignment: .leading, spacing: 4) {
                Text(cycle.dateStart.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let endDate = cycle.dateEnding {
                    HStack(spacing: 4) {
                        Text("\(cycle.dateStart.formattedTime) → \(endDate.formattedTime)")
                            .font(.subheadline)

                        Text("(\(cycle.dateStart.formattedInterval(to: endDate)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("En cours...")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            // Quality label
            Text(cycle.qualityDescription)
                .font(.caption)
                .foregroundColor(cycle.sleepQuality.qualityColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 8) {
        SleepHistoryRow(cycle: PreviewDataProvider.completedSleepCycle)

        SleepHistoryRow(cycle: PreviewDataProvider.badQualityCycle)

        SleepHistoryRow(cycle: PreviewDataProvider.activeSleepCycle)
    }
    .padding()
}

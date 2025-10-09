//
//  HistorySection.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct HistorySection: View {
    let cycles: [SleepCycle]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Historique (7 derniers jours)")
                .font(.headline)
                .padding(.horizontal)

            LazyVStack(spacing: 8) {
                ForEach(cycles) { cycle in
                    SleepHistoryRow(cycle: cycle)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HistorySection(cycles: PreviewDataProvider.sampleSleepCycles)
}

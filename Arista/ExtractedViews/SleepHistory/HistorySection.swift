//
//  HistorySection.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI
import CustomLabels

struct HistorySection: View {
    let cycles: [SleepCycleDisplay]

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
            .animation(.default, value: viewModel.historyCycles)
            .listStyle(.plain)
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.showManualEntry) {
            EditSleepCycleModal(viewModel: viewModel)
        }
    }
}

#Preview {
    HistorySection(viewModel: PreviewDataProvider.makeSleepViewModel())
}

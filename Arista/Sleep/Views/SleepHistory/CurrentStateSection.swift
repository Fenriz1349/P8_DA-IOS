//
//  CurrentStateSection.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct CurrentStateSection: View {
    @ObservedObject var viewModel: SleepViewModel

    var body: some View {
        VStack(spacing: 8) {
            switch viewModel.currentState {
            case .none:
                Text("Aucun cycle de sommeil")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))

            case .active(let cycle):
                VStack {
                    Text("Sommeil en cours")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Depuis \(cycle.dateStart.formattedTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))

            case .completed(let cycle):
                VStack {
                    Text("Dernier sommeil")
                        .font(.headline)
                    SleepHistoryRow(cycle: cycle)
                }
            }
        }
        .onTapGesture {
            viewModel.openEditModal(for: viewModel.currentCycle)
        }
        .cornerRadius(12)
    }
}

#Preview {
    CurrentStateSection(viewModel: PreviewSleepDataProvider.noCycleViewModel)
    CurrentStateSection(viewModel: PreviewSleepDataProvider.activeCycleViewModel)
    CurrentStateSection(viewModel: PreviewSleepDataProvider.editCycleViewModel)
}

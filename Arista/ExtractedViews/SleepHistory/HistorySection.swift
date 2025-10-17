//
//  HistorySection.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI
import CustomLabels

struct HistorySection: View {
    @ObservedObject var viewModel: SleepViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Historique (7 derniers jours)")
                .font(.headline)
                .padding(.horizontal)

            List {
                ForEach(viewModel.historyCycles) { cycle in
                    SleepHistoryRow(cycle: cycle)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteHistoryCycle(cycle)
                                }
                            } label: {
                                CustomButtonIcon(icon: "trash", color: .red)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                }
            }
            .frame(height: CGFloat(viewModel.historyCycles.count) * 70)
            .listStyle(.plain)
        }
        .sheet(isPresented: $viewModel.showManualEntry) {
            EditSleepCycleModal(viewModel: viewModel)
        }
    }
}



#Preview {
    HistorySection(viewModel: PreviewDataProvider.makeSleepViewModel())
}

//
//  HistorySection.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI
import CustomLabels

struct SleepHistorySection: View {
    @ObservedObject var viewModel: SleepViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("sleep.history.title".localized)
                .font(.headline)
                .padding(.horizontal)

            List {
                ForEach(viewModel.historyCycles) { cycle in
                    SleepHistoryRow(cycle: cycle)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.openEditModal(for: cycle)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteHistoryCycle(cycle)
                                }
                            } label: {
                                CustomButtonIcon(icon: "trash", color: .red)
                            }
                            Button {
                                viewModel.openEditModal(for: cycle)
                            } label: {
                                CustomButtonIcon(icon: "pencil", color: .yellow)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $viewModel.showEditModal) {
            EditSleepCycleModal(viewModel: viewModel)
        }
    }
}

#Preview {
    SleepHistorySection(viewModel: PreviewSleepDataProvider.activeAndHistoryViewModel)
}

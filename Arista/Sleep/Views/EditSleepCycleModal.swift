//
//  EditSleepCycleModal.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI
import CustomLabels

struct EditSleepCycleModal: View {
    @ObservedObject var viewModel: SleepViewModel
#warning("Trouver un moyen d'afficher toasty même sur une modale")
    @EnvironmentObject private var toastyManager: ToastyManager


    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                SleepClockView(sleepCycle: viewModel.editingCycle, size: 200)
                VStack(spacing: 16) {
                    DatePicker(
                        "Heure de coucher",
                        selection: $viewModel.manualStartDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    DatePicker(
                        "Heure de réveil",
                        selection: $viewModel.manualEndDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                GradePicker(title: viewModel.title, quality: $viewModel.selectedQuality)
                Button(action: viewModel.saveCycle) {
                    SaveButton()
                }
                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.editingCycle != nil ? "Modifier" : "Nouveau cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.cancelEdit()
                    }
                }
            }
            .onAppear {
                viewModel.configureToasty(toastyManager: toastyManager)
            }
        }
    }
}

#Preview("New Cycle") {
    EditSleepCycleModal(viewModel: PreviewSleepDataProvider.newCycleViewModel)
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

#Preview("Edit Cycle") {
    EditSleepCycleModal(viewModel: PreviewSleepDataProvider.activeCycleViewModel)
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

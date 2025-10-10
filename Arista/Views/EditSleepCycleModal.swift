//
//  EditSleepCycleModal.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct EditSleepCycleModal: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SleepViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Date pickers
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
                SleepQualityPicker(quality: $viewModel.selectedQuality)

                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.isEditingLastCycle ? "Modifier" : "Nouveau cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.cancelManualEntry()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                   SaveSleepButton(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview("New Cycle") {
    EditSleepCycleModal(viewModel: PreviewDataProvider.makeSleepViewModel())
}

#Preview("Edit Cycle") {
    let viewModel = PreviewDataProvider.makeSleepViewModel()
    viewModel.editLastCycle()
    return EditSleepCycleModal(viewModel: viewModel)
}

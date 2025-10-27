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

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                SleepClockView(sleepCycle: viewModel.editingCycle, size: 200)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        DatePicker(
                            "Heure de coucher",
                            selection: $viewModel.manualStartDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .onChange(of: viewModel.manualStartDate) {
                            viewModel.validateDates()
                        }

                        DatePicker(
                            "Heure de réveil",
                            selection: $viewModel.manualEndDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .onChange(of: viewModel.manualEndDate) {
                            viewModel.validateDates()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.dateValidationState.borderColor, lineWidth: 2)
                    )
                    .cornerRadius(8)
                    
                    if let errorMessage = viewModel.dateErrorMessage {
                        HStack {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .transition(.opacity)
                    }
                }

                GradePicker(title: viewModel.title, quality: $viewModel.selectedQuality)

                ValidatedButton(
                    iconLeading: "checkmark",
                    title: "Enregistrer",
                    color: viewModel.dateValidationState == .invalid ? .gray : .blue,
                    isEnabled: viewModel.dateValidationState != .invalid,
                    action: viewModel.saveCycle
                )

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.cancelEdit()
                    }
                }
            }
        }
    }
}

#Preview("New Cycle") {
    EditSleepCycleModal(viewModel: PreviewSleepDataProvider.newCycleViewModel)
}

#Preview("Edit Cycle") {
    EditSleepCycleModal(viewModel: PreviewSleepDataProvider.activeCycleViewModel)
}

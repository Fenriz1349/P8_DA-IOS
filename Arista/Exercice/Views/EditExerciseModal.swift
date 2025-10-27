//
//  EditExerciseModal.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import SwiftUI
import CustomLabels

struct EditExerciseModal: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type d'exercice")
                        .font(.headline)
                    ExerciseTypeGrid(selectedType: $viewModel.selectedType)
                }

                HStack {
                    DatePicker(
                        "Sélectionnez une date",
                        selection: $viewModel.date,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    DurationStepper(title: "Durée", value: $viewModel.duration)
                        .onChange(of: viewModel.duration) {
                            viewModel.validateData()
                        }
                }

                HStack {
                    GradePicker(title: "Intensité", quality: $viewModel.intensity)
                        .onChange(of: viewModel.intensity) {
                            viewModel.validateData()
                        }
                    Text(viewModel.caloriesBurned)
                }

                ValidatedButton(
                    iconLeading: "checkmark",
                    title: "Enregistrer",
                    color: viewModel.validationState == .invalid ? .gray : .blue,
                    isEnabled: viewModel.validationState != .invalid,
                    action: viewModel.saveExercise
                )
                .padding(.top, 12)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.showEditModal = false
                    }
                }
            }
        }
    }
}

#Preview("New Exercise") {
    EditExerciseModal(viewModel: PreviewExerciseDataProvider.newExerciseViewModel)
}

#Preview("Edit Exercise") {
    EditExerciseModal(viewModel: PreviewExerciseDataProvider.editExerciseViewModel)
}

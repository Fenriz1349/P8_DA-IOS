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
    @EnvironmentObject private var toastyManager: ToastyManager

    var body: some View {
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
            }
            HStack {
                GradePicker(title: "Intensité", quality: $viewModel.intensity)
                Text(viewModel.caloriesBurned)
            }

            Button(action: viewModel.saveExercise) {
                SaveButton()
            }
            .padding(.top, 12)

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    viewModel.showEditModal = false
                }
            }
        }
        .onAppear {
            viewModel.configureToasty(toastyManager: toastyManager)
        }
    }
}

#Preview("New Exercise") {
    EditExerciseModal(viewModel: PreviewExerciseDataProvider.newExerciseViewModel)
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

#Preview("Edit Exercise") {
    EditExerciseModal(viewModel: PreviewExerciseDataProvider.editExerciseViewModel)
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CustomLabels

struct ExerciseView: View {
    @ObservedObject var viewModel: ExerciseViewModel
    @EnvironmentObject private var toastyManager: ToastyManager

    var body: some View {
        VStack(spacing: 20) {
            ExerciseHistorySection(viewModel: viewModel)
            Button {
                viewModel.openEditModal(for: nil)
            } label: {
                CustomButtonLabel(iconLeading: "plus", message: "Ajouter", color: .blue)
            }
        }
        .padding()
        .navigationTitle("Exercice")
        .onAppear {
            viewModel.configureToasty(toastyManager: toastyManager)
        }
    }
}

#Preview("Liste des exercices") {
    ExerciseView(viewModel: PreviewExerciseDataProvider.filledViewModel)
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

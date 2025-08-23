//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddExerciseViewModel

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Catégorie", text: $viewModel.category)
                    TextField("Heure de démarrage", text: $viewModel.startTime)
                    TextField("Durée (en minutes)", text: $viewModel.duration)
                    TextField("Intensité (0 à 10)", text: $viewModel.intensity)
                }.formStyle(.grouped)
                Spacer()
                Button("Ajouter l'exercice") {
                    if viewModel.addExercise() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }.buttonStyle(.borderedProminent)
            }
            .navigationTitle("Nouvel Exercice ...")
        }
    }
}

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PreviewDataProvider.PreviewContext))
}

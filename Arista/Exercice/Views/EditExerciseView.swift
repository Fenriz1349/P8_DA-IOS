//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct EditExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddExerciseViewModel

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("category", text: $viewModel.category)
                    TextField("hourStart", text: $viewModel.startTime)
                    TextField("length", text: $viewModel.duration)
                    TextField("intensity", text: $viewModel.intensity)
                }.formStyle(.grouped)
                Spacer()
                Button("addExercice") {
                    if viewModel.addExercise() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }.buttonStyle(.borderedProminent)
            }
            .navigationTitle("newExercice")

        }
    }
}

#Preview {
    EditExerciseView(viewModel: AddExerciseViewModel(context: PreviewDataProvider.PreviewContext))
}

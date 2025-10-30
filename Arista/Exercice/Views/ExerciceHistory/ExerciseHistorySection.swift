//
//  ExerciseHistorySection.swift
//  Arista
//
//  Created by Julien Cotte on 21/10/2025.
//

import SwiftUI
import CustomLabels

struct ExerciseHistorySection: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("exercise.history.title")
                .font(.headline)
                .padding(.horizontal)

            List {
                ForEach(viewModel.exercices) { exercise in
                    ExerciseHistoryRow(exercise: exercise)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.openEditModal(for: exercise)
                        }
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteExercise(exercise)
                                }
                            } label: {
                                CustomButtonIcon(icon: "trash", color: .red)
                            }
                            Button {
                                viewModel.openEditModal(for: exercise)
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
            EditExerciseModal(viewModel: viewModel)
        }
    }
}

#Preview {
    ExerciseHistorySection(viewModel: PreviewExerciseDataProvider.filledViewModel)
}

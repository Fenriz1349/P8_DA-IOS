//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @State private var showingAddExerciseView = false
    
    var body: some View {
        NavigationView {
            List(viewModel.exercises) { exercise in
                HStack {
                    Image(systemName: iconForCategory(exercise.category))
                    VStack(alignment: .leading) {
                        Text(exercise.category)
                            .font(.headline)
                        Text("length\(exercise.duration)min")
                            .font(.subheadline)
                        Text(exercise.date.formatted())
                            .font(.subheadline)
                        
                    }
                    Spacer()
                    IntensityIndicator(intensity: exercise.intensity)
                }
            }
            .navigationTitle("exercices")
            .navigationBarItems(trailing: Button(action: {
                showingAddExerciseView = true
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $showingAddExerciseView) {
            AddExerciseView(viewModel: AddExerciseViewModel(context: viewModel.viewContext))
        }
        
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Football":
            return "sportscourt"
        case "Natation":
            return "waveform.path.ecg"
        case "Running":
            return "figure.run"
        case "Marche":
            return "figure.walk"
        case "Cyclisme":
            return "bicycle"
        default:
            return "questionmark"
        }
    }
}

struct IntensityIndicator: View {
    var intensity: Int
    
    var body: some View {
        Circle()
            .fill(colorForIntensity(intensity))
            .frame(width: 10, height: 10)
    }
    
    func colorForIntensity(_ intensity: Int) -> Color {
        switch intensity {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    ExerciseListView(viewModel: ExerciseListViewModel(context: PreviewDataProvider.PreviewContext))
}

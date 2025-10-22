//
//  PreviewExerciseDataProvider.swift
//  Arista
//
//  Created by Julien Cotte on 21/10/2025.
//

import SwiftUI
import CoreData

@MainActor
struct PreviewExerciseDataProvider {

    /// Context helpers
    private static var context: NSManagedObjectContext {
        PreviewDataProvider.PreviewContext
    }

    private static var user: User {
        PreviewDataProvider.sampleUser
    }

    private static var calendar: Calendar { .current }

    /// ViewModel Factory
    static func makePreviewViewModel() -> ExerciseViewModel {
        let mockCoordinator = PreviewDataProvider.sampleCoordinator
        let mockManager = ExerciceDataManager(container: PreviewDataProvider.previewData.container)

        let viewModel = try! ExerciseViewModel(
            appCoordinator: mockCoordinator,
            dataManager: mockManager
        )

        viewModel.exercices = PreviewExerciseDataProvider.sampleExercises
        return viewModel
    }

    /// Previews
    static var emptyViewModel: ExerciseViewModel {
        let viewModel = makePreviewViewModel()
        viewModel.exercices = []
        return viewModel
    }

    static var filledViewModel: ExerciseViewModel {
        let viewModel = makePreviewViewModel()
        viewModel.exercices = PreviewExerciseDataProvider.sampleExercises
        return viewModel
    }

    /// Sample Data
    static var sampleExercises: [ExerciceDisplay] {
        let now = Date()
        return [
            ExerciceDisplay(
                id: UUID(),
                date: now.addingTimeInterval(-3600 * 2),
                duration: 45,
                intensity: 7,
                type: .running
            ),
            ExerciceDisplay(
                id: UUID(),
                date: now.addingTimeInterval(-86400),
                duration: 60,
                intensity: 6,
                type: .swimming
            ),
            ExerciceDisplay(
                id: UUID(),
                date: now.addingTimeInterval(-2 * 86400),
                duration: 30,
                intensity: 4,
                type: .yoga
            ),
            ExerciceDisplay(
                id: UUID(),
                date: now.addingTimeInterval(-3 * 86400),
                duration: 90,
                intensity: 8,
                type: .cycling
            ),
            ExerciceDisplay(
                id: UUID(),
                date: now.addingTimeInterval(-4 * 86400),
                duration: 120,
                intensity: 9,
                type: .football
            )
        ]
    }
    
    static var randomExercice: ExerciceDisplay {
        sampleExercises.randomElement()!
    }

    static var newExerciseViewModel: ExerciseViewModel {
        let viewModel = makePreviewViewModel()
        viewModel.showEditModal = true
        viewModel.selectedExercice = nil
        viewModel.duration = 30
        viewModel.intensity = 5
        viewModel.selectedType = .running
        return viewModel
    }

    static var editExerciseViewModel: ExerciseViewModel {
        let vm = makePreviewViewModel()
        vm.showEditModal = true
        vm.selectedExercice = sampleExercises.first
        if let exercise = vm.selectedExercice {
            vm.duration = exercise.duration
            vm.intensity = exercise.intensity
            vm.selectedType = exercise.type
            vm.date = exercise.date
        }
        return vm
    }

}

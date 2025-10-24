//
//  ExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

@MainActor
final class ExerciseViewModel: ObservableObject {

    /// Dependencies
    private let appCoordinator: AppCoordinator
    private let exerciceDataManager: ExerciceDataManager
    let currentUser: User

    /// Published properties
    @Published var toastyManager: ToastyManager?
    @Published var exercices: [ExerciceDisplay] = []
    @Published var selectedExercice: ExerciceDisplay?
    @Published var showEditModal = false
    @Published var lastError: Error?
    @Published var lastSelectedType: ExerciceType = .other

    /// Fields for editing/adding
    @Published var selectedType: ExerciceType = .other
    @Published var date: Date = Date()
    @Published var duration: Int = 30
    @Published var intensity: Int = 5

    var caloriesBurned: String {
        return "\(Int(Double(duration) * Double(intensity) * selectedType.calorieFactor)) kcal"
    }

    /// Init
    init(appCoordinator: AppCoordinator, dataManager: ExerciceDataManager? = nil) throws {
        self.appCoordinator = appCoordinator
        self.exerciceDataManager = dataManager ?? ExerciceDataManager()
        self.currentUser = try appCoordinator.validateCurrentUser()
        reloadAll()
    }

    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    /// Fetch
    func reloadAll() {
        do {
            let items = try exerciceDataManager.fetchLastWeekExercices(for: currentUser)
            exercices = Exercice.mapToDisplay(from: items)
        } catch {
            lastError = error
        }
    }

    /// Create / Update
    func saveExercise() {
        do {
            if let selected = selectedExercice {
                try exerciceDataManager.updateExercice(
                    by: selected.id,
                    date: date,
                    type: selectedType,
                    duration: duration,
                    intensity: intensity
                )
            } else {
                _ = try exerciceDataManager.createExercice(
                    for: currentUser,
                    date: date,
                    duration: duration,
                    type: selectedType,
                    intensity: intensity
                )
            }
            lastSelectedType = selectedType
            reloadAll()
            showEditModal = false
        } catch {
            lastError = error
        }
    }

    /// Delete
    func deleteExercise(_ exercice: ExerciceDisplay) {
        do {
            let target = try  exerciceDataManager.fetchExercice(by: exercice.id)
            try exerciceDataManager.deleteExercice(target)
            reloadAll()
        } catch {
            lastError = error
        }
    }

    /// Modal handling
    func openEditModal(for exercice: ExerciceDisplay? = nil) {
        selectedExercice = exercice
        if let exercice {
            date = exercice.date
            duration = exercice.duration
            intensity = exercice.intensity
            selectedType = exercice.type
        } else {
            date = Date()
            duration = 30
            intensity = 5
            selectedType = lastSelectedType
        }
        showEditModal = true
    }
}

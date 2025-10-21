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
    private let currentUser: User

    /// Published properties
    @Published var toastyManager: ToastyManager?
    @Published var exercices: [ExerciceDisplay] = []
    @Published var selectedExercice: ExerciceDisplay?
    @Published var showEditModal = false
    @Published var lastError: Error?

    /// Fields for editing/adding
    @Published var selectedType: ExerciceType = .other
    @Published var date: Date = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 5

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
                    duration: Int16(duration),
                    intensity: Int16(intensity)
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
            reloadAll()
            showEditModal = false
        } catch {
            lastError = error
        }
    }

    /// Delete
    func deleteExercise(_ exercice: ExerciceDisplay) {
        do {
            let items = try exerciceDataManager.fetchExercices(for: currentUser)
            if let target = items.first(where: { $0.id == exercice.id }) {
                try exerciceDataManager.deleteExercice(target)
                reloadAll()
            }
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
            duration = 0
            intensity = 5
            selectedType = .other
        }
        showEditModal = true
    }
}

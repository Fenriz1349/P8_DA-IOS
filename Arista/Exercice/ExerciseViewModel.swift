//
//  ExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CustomTextFields

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
    @Published var validationState: ValidationState = .neutral

    var caloriesBurned: String {
        return "\(Int(Double(duration) * Double(intensity) * selectedType.calorieFactor)) kcal"
    }

    /// Initializes the ViewModel with required dependencies and validates the current user
    /// - Parameters:
    ///   - appCoordinator: The app coordinator managing navigation and user state
    ///   - dataManager: Manager for exercise data operations (defaults to new instance)
    /// - Throws: Error if no valid user is logged in
    init(appCoordinator: AppCoordinator, dataManager: ExerciceDataManager? = nil) throws {
        self.appCoordinator = appCoordinator
        self.exerciceDataManager = dataManager ?? ExerciceDataManager()
        self.currentUser = appCoordinator.currentUser
        reloadAll()
    }

    /// Configures the toasty notification manager
    /// - Parameter toastyManager: The ToastyManager instance to use for notifications
    func configureToasty(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    /// Reloads all exercises from the last 7 days for the current user
    func reloadAll() {
        do {
            let items = try exerciceDataManager.fetchExercices(for: currentUser)
            exercices = Exercice.mapToDisplay(from: items)
        } catch {
            lastError = error
        }
    }

    /// Validates the current form data (duration and intensity)
    func validateData() {
        validationState = (intensity >= 0 && intensity <= 10 && duration >= 0) ? .valid : .invalid
    }

    /// Resets the validation state to neutral
    func resetValidation() {
        validationState = .neutral
    }

    /// Saves the current exercise (creates new or updates existing)
    func saveExercise() {
        validateData()

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
            resetValidation()
        } catch {
            lastError = error
        }
    }

    /// Deletes a specific exercise
    /// - Parameter exercice: The exercise display model to delete
    func deleteExercise(_ exercice: ExerciceDisplay) {
        do {
            let target = try  exerciceDataManager.fetchExercice(by: exercice.id)
            try exerciceDataManager.deleteExercice(target)
            reloadAll()
        } catch {
            lastError = error
        }
    }

    /// Opens the edit modal for creating a new exercise or editing an existing one
    /// - Parameter exercice: The exercise to edit, or nil to create a new one
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
        resetValidation()
        showEditModal = true
    }
}

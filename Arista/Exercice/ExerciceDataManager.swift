//
//  ExerciceDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 20/10/2025.
//

import CoreData

enum ExerciceDataManagerError: Error, Equatable, LocalizedError {
    case exerciceNotFound
    case failedToSave
    case invalidData

    var errorDescription: String? {
        switch self {
        case .exerciceNotFound: return "error.exercise.notFound".localized
        case .failedToSave: return "error.exercise.failedToSave".localized
        case .invalidData: return "error.exercise.invalidData".localized
        }
    }
}

final class ExerciceDataManager {
    private let container: NSPersistentContainer
    private let userDataManager: UserDataManager
    private let goalManager: GoalDataManager
    
    init(container: NSPersistentContainer = PersistenceController.shared.container,
         userDataManager: UserDataManager? = nil,
         goalManager: GoalDataManager? = nil) {
        self.container = container
        self.userDataManager = userDataManager ?? UserDataManager(container: container)
        self.goalManager = goalManager ?? GoalDataManager(container: container)
    }

    /// Creates a new exercise for a specific user
    /// - Parameters:
    ///   - user: The user for whom to create the exercise
    ///   - date: The date of the exercise (defaults to current date)
    ///   - duration: The duration in minutes (must be non-negative)
    ///   - type: The type of exercise (defaults to .other)
    ///   - intensity: The intensity level from 0 to 10 (defaults to 5)
    /// - Returns: The newly created Exercice entity
    /// - Throws: ExerciceDataManagerError.invalidData if parameters are invalid, or .failedToSave if save fails
    @discardableResult
    func createExercice(for user: User,
                        date: Date = Date(),
                        duration: Int = 0,
                        type: ExerciceType = .other,
                        intensity: Int = 5) throws -> Exercice {
        guard intensity >= 0 && intensity <= 10 && duration >= 0 else {
            throw ExerciceDataManagerError.invalidData
        }

        let context = container.viewContext
        let exercice = Exercice(context: context)
        exercice.id = UUID()
        exercice.date = date
        exercice.duration = Int16(duration)
        exercice.intensity = Int16(intensity)
        exercice.type = type.rawValue
        exercice.user = user

        do {
            try goalManager.fetchOrCreateGoal(for: user, date: date)
            try context.save()
            return exercice
        } catch {
            throw ExerciceDataManagerError.failedToSave
        }
    }

    /// Fetches a specific exercise by its unique identifier
    /// - Parameter id: The UUID of the exercise to fetch
    /// - Returns: The matching Exercice entity
    /// - Throws: ExerciceDataManagerError.exerciceNotFound if no exercise exists with the given ID
    func fetchExercice(by id: UUID) throws -> Exercice {
        let context = container.viewContext
        let request: NSFetchRequest<Exercice> = Exercice.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        guard let exercice = try context.fetch(request).first else {
            throw ExerciceDataManagerError.exerciceNotFound
        }

        return exercice
    }

    /// Fetches all exercises for a specific user
    /// - Parameter user: The user whose exercises to fetch
    /// - Returns: An array of Exercice entities sorted by date (descending)
    /// - Throws: Error if the fetch request fails
    func fetchExercices(for user: User) throws -> [Exercice] {
        let context = container.viewContext
        let request: NSFetchRequest<Exercice> = Exercice.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return try context.fetch(request)
    }

    /// Fetches exercises from the last 7 days for a specific user
    /// - Parameter user: The user whose exercises to fetch
    /// - Returns: An array of Exercice entities from the last week
    /// - Throws: Error if the fetch request fails
    func fetchLastWeekExercices(for user: User) throws -> [Exercice] {
        let allExercices = try fetchExercices(for: user)

        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return allExercices
        }

        return allExercices.filter { $0.date >= oneWeekAgo }
    }

    /// Updates an existing exercise with new values
    /// - Parameters:
    ///   - id: The UUID of the exercise to update
    ///   - date: The new date for the exercise
    ///   - type: The new exercise type
    ///   - duration: The new duration in minutes (must be non-negative)
    ///   - intensity: The new intensity level from 0 to 10
    /// - Throws: ExerciceDataManagerError.invalidData if parameters are invalid,
    ///           .exerciceNotFound if exercise doesn't exist, or .failedToSave if save fails
    func updateExercice(by id: UUID,
                        date: Date,
                        type: ExerciceType,
                        duration: Int,
                        intensity: Int) throws {
        guard intensity >= 0 && intensity <= 10 && duration >= 0 else {
            throw ExerciceDataManagerError.invalidData
        }

        let context = container.viewContext
        let exercice = try fetchExercice(by: id)

        exercice.date = date
        exercice.type = type.rawValue
        exercice.duration = Int16(duration)
        exercice.intensity = Int16(intensity)

        do {
            try goalManager.fetchOrCreateGoal(for: exercice.user, date: date)
            try context.save()
        } catch {
            throw ExerciceDataManagerError.failedToSave
        }
    }

    /// Deletes a specific exercise from the database
    /// - Parameter exercice: The Exercice entity to delete
    /// - Throws: ExerciceDataManagerError.exerciceNotFound if exercise doesn't exist, or .failedToSave if save fails
    func deleteExercice(_ exercice: Exercice) throws {
        let context = container.viewContext
        let exercice = try fetchExercice(by: exercice.id)
        context.delete(exercice)
        do {
            try context.save()
        } catch {
            throw ExerciceDataManagerError.failedToSave
        }
    }
}

#if DEBUG
extension ExerciceDataManager {
    var viewContext: NSManagedObjectContext { container.viewContext }
}
#endif

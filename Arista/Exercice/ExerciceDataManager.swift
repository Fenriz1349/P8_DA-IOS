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
        case .exerciceNotFound: return "L'exercice demandé est introuvable."
        case .failedToSave: return "Impossible d'enregistrer l'exercice."
        case .invalidData: return "Les données fournies sont invalides."
        }
    }
}

final class ExerciceDataManager {
    private let container: NSPersistentContainer
    private let userDataManager: UserDataManager

    init(container: NSPersistentContainer = PersistenceController.shared.container,
         userDataManager: UserDataManager? = nil) {
        self.container = container
        self.userDataManager = userDataManager ?? UserDataManager(container: container)
    }

    /// Create
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
            try context.save()
            return exercice
        } catch {
            throw ExerciceDataManagerError.failedToSave
        }
    }

    /// Fetch
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

    func fetchExercices(for user: User) throws -> [Exercice] {
        let context = container.viewContext
        let request: NSFetchRequest<Exercice> = Exercice.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return try context.fetch(request)
    }

    func fetchLastWeekExercices(for user: User) throws -> [Exercice] {
        let allExercices = try fetchExercices(for: user)

        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return allExercices
        }

        return allExercices.filter { $0.date >= oneWeekAgo }
    }

    /// Update
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
            try context.save()
        } catch {
            throw ExerciceDataManagerError.failedToSave
        }
    }

    /// Delete
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

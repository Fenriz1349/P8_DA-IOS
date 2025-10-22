//
//  ExerciceDataManager.swift
//  Arista
//
//  Created by Julien Cotte on 20/10/2025.
//

import Foundation
import CoreData

enum ExerciceDataManagerError: Error, Equatable, LocalizedError {
    case exerciceNotFound

    var errorDescription: String? {
        switch self {
        case .exerciceNotFound: return "Exercice non trouvé."
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

    // MARK: - Create
    func createExercice(for user: User,
                        date: Date = Date(),
                        duration: Int = 0,
                        type: ExerciceType = .other,
                        intensity: Int = 5) throws -> Exercice {
        let context = container.viewContext

        let exercice = Exercice(context: context)
        exercice.id = UUID()
        exercice.date = date
        exercice.duration = Int16(duration)
        exercice.intensity = Int16(intensity)
        exercice.user = user

        try context.save()

        return exercice
    }

    // MARK: - Fetch Methods
    func fetchExercices(for user: User) throws -> [Exercice] {
        let context = container.viewContext

        let request: NSFetchRequest<Exercice> = Exercice.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return try context.fetch(request)
    }

    func fetchLastWeekExercices(for user: User) throws -> [Exercice] {
        let allExercices = try fetchExercices(for: user)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        return allExercices.filter { $0.date >= sevenDaysAgo }
    }

    // MARK: - Delete Methods
    func deleteExercice(_ exercice: Exercice) throws {
        let context = container.viewContext
        context.delete(exercice)
        try context.save()
    }

    // MARK: - Update Methods
    func updateExercice(by id: UUID, date: Date, type: ExerciceType, duration: Int16, intensity: Int16) throws {
        let context = container.viewContext
        let request: NSFetchRequest<Exercice> = Exercice.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        guard let exercice = try context.fetch(request).first else {
            throw ExerciceDataManagerError.exerciceNotFound
        }

        exercice.date = date
        exercice.type = type.rawValue
        exercice.duration = duration
        exercice.intensity = intensity

        try context.save()
    }

}

#if DEBUG
extension ExerciceDataManager {
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
#endif

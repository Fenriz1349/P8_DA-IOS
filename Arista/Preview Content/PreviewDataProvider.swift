//
//  PreviewDataProvider.swift
//  Arista
//
//  Created by Julien Cotte on 13/08/2025.
//

import SwiftUI
import CoreData

@MainActor
struct PreviewDataProvider {

    private struct ExerciseTestData {
        let type: ExerciceType
        let duration: Int64
        let intensity: Int64
        let daysAgo: Int
    }

    /// Main Container for preview
    static var previewData: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let user = createSampleUser(in: context)
        createSampleExercises(for: user, in: context)

        do {
            try context.save()
        } catch {
            print("Erreur lors de la création des données de preview: \(error)")
        }

        return controller
    }()

    static var PreviewContext: NSManagedObjectContext {
        previewData.container.viewContext
    }

    static var empty: PersistenceController = {
        return PersistenceController(inMemory: true)
    }()
}

extension PreviewDataProvider {

    static var sampleUser: User {
        let context = PreviewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        if let user = try? context.fetch(request).first {
            return user
        } else {
            let newUser = createSampleUser(in: context)
            try? context.save()
            return newUser
        }
    }

    static func createSampleUser(in context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.salt = UUID()
        user.firstName = "Charlotte"
        user.lastName = "Corino"
        user.email = "charlotte.corino@preview.com"
        user.hashPassword = PasswordHasher.hash(password: "Password123!", salt: user.salt)
        user.calorieGoal = 2000
        user.sleepGoal = 480 // 8 heures
        user.waterGoal = 25 // 2.5L
        user.genderEnum = .female
        user.birthdate = Calendar.current.date(from: DateComponents(year: 1990, month: 3, day: 15))!
        user.height = 165
        user.weight = 60
        user.isLogged = true
        return user
    }

    static func createSampleExercises(for user: User, in context: NSManagedObjectContext) {
        let exercisesData = [
            ExerciseTestData(type: .running, duration: 45, intensity: 7, daysAgo: 0),
            ExerciseTestData(type: .swimming, duration: 60, intensity: 6, daysAgo: -1),
            ExerciseTestData(type: .football, duration: 120, intensity: 8, daysAgo: -2),
            ExerciseTestData(type: .yoga, duration: 30, intensity: 4, daysAgo: -3),
            ExerciseTestData(type: .cycling, duration: 90, intensity: 7, daysAgo: -4)
        ]

        for data in exercisesData {
            let exercise = Exercice(context: context)
            exercise.typeEnum = data.type
            exercise.duration = Int16(data.duration)
            exercise.intensity = Int16(data.intensity)
            exercise.date = Calendar.current.date(byAdding: .day, value: data.daysAgo, to: Date()) ?? Date()
            exercise.user = user
        }
    }
}

// MARK: - Preview AppCoordinator
extension PreviewDataProvider {
    static var sampleCoordinator: AppCoordinator {
        let dataManager = UserDataManager(container: previewData.container)
        let coordinator = AppCoordinator(dataManager: dataManager)

        let context = previewData.container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        if let user = try? context.fetch(request).first {
            try? coordinator.login(id: user.id)
        }

        return coordinator
    }

    static var sampleToastyManager: ToastyManager {
        ToastyManager()
    }

    // MARK: - Preview ViewModels
    static var sampleAuthenticationViewModel: AuthenticationViewModel {
        AuthenticationViewModel(appCoordinator: sampleCoordinator)
    }

    static func makeSampleAccountViewModel() -> AccountViewModel {
        return try! AccountViewModel(appCoordinator: PreviewDataProvider.sampleCoordinator)
    }

    static func makeSampleEditAccountViewModel() -> EditAccountViewModel {
        return try! EditAccountViewModel(appCoordinator: PreviewDataProvider.sampleCoordinator)
    }
}

struct PreviewContainer<Content: View, VM: ObservableObject>: View {
    @ObservedObject var viewModel: VM
    let content: (VM) -> Content

    init(_ viewModel: VM, @ViewBuilder content: @escaping (VM) -> Content) {
        self.viewModel = viewModel
        self.content = content
    }

    var body: some View {
        content(viewModel)
    }
}

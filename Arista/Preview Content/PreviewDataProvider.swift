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

    /// Main Container for preview
    static var previewData: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let user = createSampleUser(in: context)
        createSampleGoals(for: user, in: context)
        createSampleExercices(for: user, in: context)
        createSampleSleepCycles(for: user, in: context)

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

/// User Creation
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
        user.firstName = "Charlotte"
        user.lastName = "Corino"
        user.calorieGoal = 500
        user.sleepGoal = 480 // 8 hours
        user.waterGoal = 25 // 2.5L
        user.stepsGoal = 8500
        return user
    }
}

// MARK: - Goals Creation
extension PreviewDataProvider {
    static func createSampleGoals(for user: User, in context: NSManagedObjectContext) {
        let today = Calendar.current.startOfDay(for: Date())

        let oneWeekGoalsData: [(water: Int16, steps: Int32)] = [
            (15, 5500),
            (20, 7000),
            (25, 9000),
            (18, 6000),
            (22, 8500),
            (16, 5000),
            (24, 10000)
        ]

        for (offset, data) in oneWeekGoalsData.enumerated() {
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { continue }

            let goal = Goal(context: context)
            goal.id = UUID()
            goal.date = date
            goal.user = user
            goal.totalWater = data.water
            goal.totalSteps = data.steps
        }
    }
}

/// Exercices Creation
extension PreviewDataProvider {
    static func createSampleExercices(for user: User, in context: NSManagedObjectContext) {
        let today = Date()

        let oneWeekExercicesData: [(offset: Int, type: ExerciceType, duration: Int, intensity: Int)] = [
            (0, .running, 30, 7),
            (0, .yoga, 45, 4),
            (1, .cycling, 60, 6),
            (2, .swimming, 45, 8),
            (3, .walking, 30, 3),
            (4, .strength, 40, 7),
            (5, .running, 25, 6),
            (6, .boxing, 50, 8)
        ]

        for data in oneWeekExercicesData {
            let date = Calendar.current.date(byAdding: .day, value: -data.offset, to: today)!

            let exercice = Exercice(context: context)
            exercice.id = UUID()
            exercice.date = date
            exercice.type = data.type.rawValue
            exercice.duration = Int16(data.duration)
            exercice.intensity = Int16(data.intensity)
            exercice.user = user
        }
    }
}

/// Sleep Cycles Creation
extension PreviewDataProvider {
    static func createSampleSleepCycles(for user: User, in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let now = Date()

        let oneWeekSleepData: [(duration: TimeInterval, quality: Int)] = [
            (7 * 3600, 6),
            (8 * 3600, 8),
            (6 * 3600, 5),
            (8.5 * 3600, 9),
            (7.5 * 3600, 7),
            (6.5 * 3600, 6),
            (8 * 3600, 8)
        ]

        for (offset, data) in oneWeekSleepData.enumerated() {
            let index = offset + 1
            guard let sleepDate = calendar.date(byAdding: .day, value: -index, to: now) else { continue }

            let sleepStart = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: sleepDate)!

            let cycle = SleepCycle(context: context)
            cycle.id = UUID()
            cycle.dateStart = sleepStart
            cycle.dateEnding = sleepStart.addingTimeInterval(data.duration)
            cycle.quality = Int16(data.quality)
            cycle.user = user
        }
    }
}

/// Preview Helpers
extension PreviewDataProvider {
    static var sampleCoordinator: AppCoordinator {
        let dataManager = UserDataManager(container: previewData.container)
        let coordinator = AppCoordinator(dataManager: dataManager)

        let context = previewData.container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()

        return coordinator
    }

    static var sampleToastyManager: ToastyManager {
        ToastyManager()
    }

    /// Preview ViewModels

    static func makeSampleUserViewModel() -> UserViewModel {
        let goalDataManager = GoalDataManager(container: previewData.container)
        return try! UserViewModel(
            appCoordinator: sampleCoordinator,
            goalDataManager: goalDataManager
        )
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

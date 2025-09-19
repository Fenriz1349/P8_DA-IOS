//
//  PreviewDataProvider.swift
//  Arista
//
//  Created by Julien Cotte on 13/08/2025.
//

import Foundation
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

        createSampleAliments(in: context)
        let user = createSampleUser(in: context)
        createSampleExercises(for: user, in: context)
        createSampleSleepCycles(for: user, in: context)
        createSampleMeals(for: user, in: context)

        do {
            try context.save()
        } catch {
            print("Erreur lors de la création des données de preview: \(error)")
        }

        return controller
    }()

    static var userOnly: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        _ = createSampleUser(in: context)

        do {
            try context.save()
        } catch {
            print("Erreur lors de la création de l'utilisateur de preview: \(error)")
        }

        return controller
    }()

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

    static func createSampleAliments(in context: NSManagedObjectContext) {
        let alimentsData = [
            ("Pomme", 95, true),
            ("Banane", 105, true),
            ("Eau", 0, false),
            ("Café", 5, false),
            ("Sandwich Jambon", 350, true),
            ("Salade César", 280, true),
            ("Yaourt Grec", 130, true),
            ("Amandes", 160, true)
        ]

        for (name, calories, isSolid) in alimentsData {
            let aliment = Aliment(context: context)
            aliment.name = name
            aliment.calPerPortion = Int16(calories)
            aliment.isSolid = isSolid
        }
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

    static func createSampleSleepCycles(for user: User, in context: NSManagedObjectContext) {
        let now = Date()
        let calendar = Calendar.current

        // Create 7 days of sleepCycle
        for daysAgo in 0...6 {
            let sleepDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now

            let bedtimeHour = Int.random(in: 22...23)
            let bedtimeMinute = Int.random(in: 0...59)

            let bedtime = calendar.date(bySettingHour: bedtimeHour,
                                      minute: bedtimeMinute,
                                      second: 0,
                                      of: sleepDate) ?? sleepDate

            let sleepDuration = Double.random(in: 6.5...9.0) * 3600 // en secondes
            let wakeupTime = bedtime.addingTimeInterval(sleepDuration)

            let quality = Int64(min(10, max(1, Int(sleepDuration / 3600 - 2))))

            let sleepCycle = SleepCycle(context: context)
            sleepCycle.dateBegging = bedtime
            sleepCycle.dateEnding = wakeupTime
            sleepCycle.quality = Int16(quality)
            sleepCycle.user = user
        }
    }

    static func createSampleMeals(for user: User, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Aliment> = Aliment.fetchRequest()
        guard let aliments = try? context.fetch(request) else { return }

        let mealTypes: [MealType] = [.breakfast, .lunch, .dinner, .snack]
        let today = Date()

        for daysAgo in 0...1 {
            let mealDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today) ?? today

            for mealType in mealTypes {
                let meal = Meal(context: context)
                meal.mealTypeEnum = mealType
                meal.date = mealDate
                meal.user = user

                let selectedAliments = Array(aliments.shuffled().prefix(Int.random(in: 1...3)))

                for aliment in selectedAliments {
                    let mealContent = MealContent(context: context)
                    mealContent.quantity = Int16.random(in: 1...2)
                    mealContent.aliment = aliment
                    mealContent.meal = meal
                }
            }
        }
    }
}

// MARK: - Convenience Accessors
extension PreviewDataProvider {

    static var PreviewContext: NSManagedObjectContext {
        previewData.container.viewContext
    }

    static var userOnlyContext: NSManagedObjectContext {
        userOnly.container.viewContext
    }

    static var emptyContext: NSManagedObjectContext {
        empty.container.viewContext
    }
}

extension PreviewDataProvider {
    // MARK: - Preview AppCoordinator
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

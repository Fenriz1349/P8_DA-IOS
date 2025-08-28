//
//  PreviewDataProvider.swift
//  Arista
//
//  Created by Julien Cotte on 13/08/2025.
//

import Foundation
import CoreData

struct PreviewDataProvider {

    /// Container principal avec des données complètes pour la plupart des previews
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

// MARK: - Private Data Creation Methods
private extension PreviewDataProvider {

    static func createSampleUser(in context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.firstName = "Charlotte"
        user.lastName = "Corino"
        user.email = "charlotte.corino@preview.com"
        user.calorieGoal = 2000
        user.sleepGoal = 480 // 8 heures
        user.waterGoal = 25 // 2.5L
        user.genderEnum = .female
        user.birthdate = Calendar.current.date(from: DateComponents(year: 1990, month: 3, day: 15))
        user.size = 165
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
            aliment.calPerPortion = Int64(calories)
            aliment.isSolid = isSolid
        }
    }

    static func createSampleExercises(for user: User, in context: NSManagedObjectContext) {
        let exercisesData: [(ExerciceType, Int64, Int64, Int)] = [
            (.running, 45, 7, 0),     // today
            (.swimming, 60, 6, -1),   // yesterday
            (.football, 120, 8, -2),  // before yesterday
            (.yoga, 30, 4, -3),       // 3 days ago
            (.cycling, 90, 7, -4)     // 4 days ago
        ]

        for (type, duration, intensity, daysAgo) in exercisesData {
            let exercise = Exercice(context: context)
            exercise.typeEnum = type
            exercise.duration = duration
            exercise.intensity = intensity
            exercise.date = Calendar.current.date(byAdding: .day, value: daysAgo, to: Date()) ?? Date()
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
            sleepCycle.dateBegging = Int64(bedtime.timeIntervalSince1970)
            sleepCycle.dateEnding = wakeupTime
            sleepCycle.quality = quality
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
                meal.date = getMealDateTime(for: mealType, on: mealDate)
                meal.user = user

                let selectedAliments = Array(aliments.shuffled().prefix(Int.random(in: 1...3)))

                for aliment in selectedAliments {
                    let mealContent = MealContent(context: context)
                    mealContent.quantity = Int64.random(in: 1...2)
                    mealContent.aliment = aliment
                    mealContent.meal = meal
                }
            }
        }
    }

    static func getMealDateTime(for mealType: MealType, on date: Date) -> Date {
        let calendar = Calendar.current
        let hour: Int

        switch mealType {
        case .breakfast: hour = 8
        case .lunch: hour = 12
        case .dinner: hour = 19
        case .snack: hour = 16
        case .water: hour = 10
        }

        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
    }
}

// MARK: - Convenience Accessors
extension PreviewDataProvider {

    /// Retourne le contexte du container avec données riches
    static var PreviewContext: NSManagedObjectContext {
        previewData.container.viewContext
    }

    /// Retourne le contexte du container avec utilisateur seulement
    static var userOnlyContext: NSManagedObjectContext {
        userOnly.container.viewContext
    }

    /// Retourne le contexte du container vide
    static var emptyContext: NSManagedObjectContext {
        empty.container.viewContext
    }
}

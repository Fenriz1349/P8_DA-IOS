//
//  SharedTestHelper.swift
//  AristaTests
//
//  Created by Julien Cotte on 14/08/2025.
//

import Foundation
import CoreData
@testable import Arista

struct SharedTestHelper {

    /// Create an unique PersistenceController for each test
    static func createTestContainer() -> PersistenceController {
        return PersistenceController(inMemory: true)
    }


    static func saveContextWithErrorHandling(_ context: NSManagedObjectContext) -> Error? {
        do {
            try context.save()
            return nil
        } catch {
            return error
        }
    }

    /// Save Helper

    static func saveContext(_ context: NSManagedObjectContext) throws {
        try context.save()
    }
}

extension SharedTestHelper {
    @discardableResult
    static func createSampleExercice(for user: User,
                                     in context: NSManagedObjectContext,
                                     date: Date = Date(),
                                     duration: Int = 30,
                                     type: ExerciceType = .running,
                                     intensity: Int = 5) -> Exercice {
        let exercice = Exercice(context: context)
        exercice.id = UUID()
        exercice.date = date
        exercice.duration = Int16(duration)
        exercice.intensity = Int16(intensity)
        exercice.type = type.rawValue
        exercice.user = user
        return exercice
    }
}

extension SharedTestHelper {
    @discardableResult
    static func createSampleSleepCycle(for user: User,
                                       in context: NSManagedObjectContext,
                                       startOffset: TimeInterval = -8 * 3600,
                                       duration: TimeInterval = 8 * 3600,
                                       quality: Int = 7) -> SleepCycle {
        let cycle = SleepCycle(context: context)
        cycle.id = UUID()
        cycle.dateStart = Date().addingTimeInterval(startOffset)
        cycle.dateEnding = cycle.dateStart.addingTimeInterval(duration)
        cycle.quality = Int16(quality)
        cycle.user = user
        return cycle
    }
}

extension SharedTestHelper {
    @discardableResult
    static func makeGoal(for user: User,
                         in context: NSManagedObjectContext,
                         date: Date,
                         water: Int16 = 20,
                         steps: Int32 = 6000) -> Goal {
        let goal = Goal(context: context)
        goal.id = UUID()
        goal.date = date
        goal.totalWater = water
        goal.totalSteps = steps
        goal.user = user
        return goal
    }

    @discardableResult
    static func makeWeekGoals(for user: User,
                              in context: NSManagedObjectContext) -> [Goal] {
        let today = Date()
        return (0..<7).compactMap { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return makeGoal(for: user, in: context, date: date, water: Int16(20 + offset))
        }
    }
}

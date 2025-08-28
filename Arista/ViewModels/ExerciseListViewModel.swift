//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

import CoreData

class ExerciseListViewModel: ObservableObject {
    @Published var exercises = [FakeExercise]()

    var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExercises()
    }

    private func fetchExercises() {
        // TODO: fetch data in CoreData and replace dumb value below with appropriate information
        exercises = [FakeExercise(), FakeExercise(), FakeExercise()]
    }
}

struct FakeExercise: Identifiable {
    var id = UUID()

    var category: String = "Football"
    var duration: Int = 120
    var intensity: Int = 8
    var date: Date = Date()
}

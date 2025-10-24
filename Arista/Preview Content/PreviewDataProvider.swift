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
        user.sleepGoal = 480 // 8 hours
        user.waterGoal = 25 // 2.5L
        user.isLogged = true
        return user
    }
}

/// Preview AppCoordinator
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

    /// Preview ViewModels
    static var sampleAuthenticationViewModel: AuthenticationViewModel {
        AuthenticationViewModel(appCoordinator: sampleCoordinator)
    }

    static func makeSampleUserViewModel() -> UserViewModel {
        return try! UserViewModel(appCoordinator: PreviewDataProvider.sampleCoordinator)
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

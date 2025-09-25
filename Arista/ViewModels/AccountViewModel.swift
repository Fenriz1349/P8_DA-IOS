//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

enum AccountViewModelError: Error {
    case noLoggedUser
}

@MainActor
final class AccountViewModel: ObservableObject {
    private let appCoordinator: AppCoordinator
    let user: User
    @Published var showEditAccount = false
    @Published var toastyManager: ToastyManager?

    init(appCoordinator: AppCoordinator) throws {
        self.appCoordinator = appCoordinator
        self.user = try Self.getCurrentUser(from: appCoordinator)
    }

    func configure(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    private static func getCurrentUser(from coordinator: AppCoordinator) throws -> User {
        guard let currentUser = coordinator.currentUser else {
            throw AccountViewModelError.noLoggedUser
        }
        return currentUser
    }

    var editAccountViewModel: EditAccountViewModel? {
        guard let editVM = try? appCoordinator.makeEditAccountViewModel() else {
            return nil
        }
        return editVM
    }

    func logout() throws {
        try appCoordinator.logout()
    }

    private func handleAccountError(_ error: Error) {
        let errorMessage: String

        if let editError = error as? AccountViewModelError {
            switch editError {
            case .noLoggedUser:
                errorMessage = "There always be a looged User at this point. Please relaunch Arista."
            }

            toastyManager?.show(message: errorMessage)
        }
    }
}

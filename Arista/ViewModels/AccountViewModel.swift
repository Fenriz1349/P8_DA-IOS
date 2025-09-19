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

    init(appCoordinator: AppCoordinator) throws {
        self.appCoordinator = appCoordinator
        self.user = try Self.getCurrentUser(from: appCoordinator)
    }

    private static func getCurrentUser(from coordinator: AppCoordinator) throws -> User {
        guard let currentUser = coordinator.currentUser else {
            throw AccountViewModelError.noLoggedUser
        }
        return currentUser
    }

    func logout() throws {
        try appCoordinator.logout()
    }
}

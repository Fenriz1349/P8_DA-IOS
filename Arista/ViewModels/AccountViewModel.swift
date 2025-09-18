//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

@MainActor
final class AccountViewModel: ObservableObject {
    private let appCoordinator: AppCoordinator

    var currentUser: User? {
        appCoordinator.currentUser
    }

    init(appCoordinator: AppCoordinator ) {
        self.appCoordinator = appCoordinator
    }

    // MARK: - Auth

    func logout() throws {
        try appCoordinator.logout()
    }
}


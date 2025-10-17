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
    let user: User
    @Published var showEditAccount = false

    init(appCoordinator: AppCoordinator) throws {
        self.appCoordinator = appCoordinator
        self.user = try appCoordinator.validateCurrentUser()
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
}

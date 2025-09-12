//
//  AuthenticationViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import Foundation
import CustomTextFields

enum AuthenticationError: Error {
    case invalidCredentials
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    private let appCoordinator: AppCoordinator

    @MainActor
    init(appCoordinator: AppCoordinator = AppCoordinator.shared) {
        self.appCoordinator = appCoordinator
    }

    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && isMailValid && isPasswordValid
    }

    var isMailValid: Bool {
        Validators.isValidEmail(email)
    }

    var isPasswordValid: Bool {
        Validators.isStrongPassword(password)
    }

    func login() throws {
        guard isFormValid else { return }

        let users = appCoordinator.dataManager.fetchAllUsers()

        guard let user = users.first(where: { $0.email == email }) else {
            throw AuthenticationError.invalidCredentials
        }

        guard user.verifyPassword(password) else {
            throw AuthenticationError.invalidCredentials
        }

        try appCoordinator.login(id: user.id)
    }
}

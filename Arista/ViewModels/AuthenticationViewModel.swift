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
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var creationMode: Bool = false

    private let appCoordinator: AppCoordinator

    @MainActor
    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    var isFormValid: Bool {
        creationMode ? isCreationFormValid : isLoginFormValid
    }

    var isLoginFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && isMailValid && isPasswordValid
    }

    var isCreationFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && !firstName.isEmpty && !lastName.isEmpty && isMailValid && isPasswordValid
    }

    var isMailValid: Bool {
        Validators.isValidEmail(email)
    }

    var isPasswordValid: Bool {
        Validators.isStrongPassword(password)
    }

    func login() throws {
        guard isLoginFormValid else { return }

        let users = appCoordinator.dataManager.fetchAllUsers()

        guard let user = users.first(where: { $0.email == email }) else {
            throw AuthenticationError.invalidCredentials
        }

        guard user.verifyPassword(password) else {
            throw AuthenticationError.invalidCredentials
        }

        try appCoordinator.login(id: user.id)
    }

    func createUserAndLogin() throws {
        try appCoordinator.dataManager.createUser(email: email,
                                                  password: password,
                                                  firstName: firstName,
                                                  lastName: lastName)
        try login()
    }
}

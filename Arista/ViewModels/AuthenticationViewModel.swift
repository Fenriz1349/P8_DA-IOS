//
//  AuthenticationViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI
import CustomTextFields

enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case validationFailed
    case emailAlreadyUsed

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email ou mot de passe incorrect. Vérifiez vos identifiants."
        case .validationFailed:
            return "Veuillez compléter correctement tous les champs requis."
        case .emailAlreadyUsed:
            return "Cette adresse email est déjà utilisée. Utilisez une adresse différente."
        }
    }
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let appCoordinator: AppCoordinator
    @Published var toastyManager: ToastyManager?

    enum ButtonState {
        case disabled, enabled, error
    }

    enum FieldType {
        case email, password, firstName, lastName
    }

    var buttonBackgroundColor: Color {
        switch buttonState {
        case .disabled:
            return .gray.opacity(0.6)
        case .enabled:
            return .green
        case .error:
            return .red
        }
    }

    // MARK: - Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var creationMode: Bool = false
    @Published var buttonState: ButtonState = .disabled

    // MARK: - Validation states for CustomTextFields
    @Published var emailValidationState: ValidationState = .neutral
    @Published var passwordValidationState: ValidationState = .neutral
    @Published var firstNameValidationState: ValidationState = .neutral
    @Published var lastNameValidationState: ValidationState = .neutral

    @MainActor
    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    func configure(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    // MARK: - Computed Properties
    var isFormValid: Bool {
        creationMode ? isCreationFormValid : isLoginFormValid
    }

    var isLoginFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && isMailValid && isPasswordValid
    }

    var isCreationFormValid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && isFirstNameValid && isLastNameValid && isLoginFormValid
    }

    var isMailValid: Bool {
        Validators.isValidEmail(email)
    }

    var isPasswordValid: Bool {
        Validators.isStrongPassword(password)
    }

    var isFirstNameValid: Bool {
        ExampleValidationRules.validateFirstName(firstName)
    }

    var isLastNameValid: Bool {
        ExampleValidationRules.validateLastName(lastName)
    }

    // MARK: - Button State Management
    func updateButtonState() {
        buttonState = isFormValid ? .enabled : .disabled
    }

    // MARK: - Validation Management
    func resetFieldValidation(_ field: FieldType) {
        switch field {
        case .email:
            if emailValidationState == .invalid {
                emailValidationState = .neutral
            }
        case .password:
            if passwordValidationState == .invalid {
                passwordValidationState = .neutral
            }
        case .firstName:
            if firstNameValidationState == .invalid {
                firstNameValidationState = .neutral
            }
        case .lastName:
            if lastNameValidationState == .invalid {
                lastNameValidationState = .neutral
            }
        }
    }

    func resetAllValidationStates() {
        emailValidationState = .neutral
        passwordValidationState = .neutral
        firstNameValidationState = .neutral
        lastNameValidationState = .neutral
    }

    func validateAllFields() -> Bool {
        var hasErrors = false

        // Validate email
        if !isMailValid {
            emailValidationState = .invalid
            hasErrors = true
        }

        // Validate password
        if !isPasswordValid {
            passwordValidationState = .invalid
            hasErrors = true
        }

        // Validate creation mode fields
        if creationMode {
            if !isFirstNameValid {
                firstNameValidationState = .invalid
                hasErrors = true
            }

            if !isLastNameValid {
                lastNameValidationState = .invalid
                hasErrors = true
            }
        }

        return !hasErrors
    }

    // MARK: - Submit Handling
    func handleSubmit() {
        if validateAllFields() {
            Task {
                do {
                    if creationMode {
                        try createUserAndLogin()
                    } else {
                        try login()
                    }
                } catch {
                    toastyManager?.showError(error)
                    showAuthError()
                }
            }
        } else {
            showValidationError()
        }
    }

    private func showValidationError() {
        buttonState = .error

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.updateButtonState()
        }
    }

    private func showAuthError() {
        resetAllValidationStates()
        buttonState = .error

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateButtonState()
        }
    }

    // MARK: - Authentication Methods
    func login() throws {
        guard isLoginFormValid else {
            throw AuthenticationError.validationFailed
        }

        let users = appCoordinator.dataManager.fetchAllUsers()

        guard let user = users.first(where: { $0.email == email }),
              user.verifyPassword(password) else {
            throw AuthenticationError.invalidCredentials
        }

        try appCoordinator.login(id: user.id)
    }

    func createUserAndLogin() throws {
        guard isCreationFormValid else {
            throw AuthenticationError.validationFailed
        }

        guard !appCoordinator.isEmailAlreadyUsed(email) else {
            throw AuthenticationError.emailAlreadyUsed
        }

        try appCoordinator.dataManager.createUser(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )

        try login()
    }
}

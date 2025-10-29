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
            return NSLocalizedString("error.auth.invalidCredentials", comment: "Invalid credentials error")
        case .validationFailed:
            return NSLocalizedString("error.auth.validationFailed", comment: "Validation failed error")
        case .emailAlreadyUsed:
            return NSLocalizedString("error.auth.emailAlreadyUsed", comment: "Email already used error")
        }
    }
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let appCoordinator: AppCoordinator
    @Published var toastyManager: ToastyManager?

    enum FieldType {
        case email, password, firstName, lastName
    }

    // MARK: - Published Properties
    
    /// User input fields
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var creationMode: Bool = false
    @Published var buttonState: ButtonValidationState = .disabled

    /// Validation states for each form field
    @Published var emailValidationState: ValidationState = .neutral
    @Published var passwordValidationState: ValidationState = .neutral
    @Published var firstNameValidationState: ValidationState = .neutral
    @Published var lastNameValidationState: ValidationState = .neutral

    // MARK: - Initialization

    @MainActor
    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    /// Configures the toast notification manager
    /// - Parameter toastyManager: Manager for displaying toast notifications
    func configure(toastyManager: ToastyManager) {
        self.toastyManager = toastyManager
    }

    // MARK: - Form Validation
    
    var isFormValid: Bool {
        creationMode ? isCreationFormValid : isLoginFormValid
    }

    var isLoginFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && isMailValid && isPasswordValid
    }

    var isCreationFormValid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && isFirstNameValid && isLastNameValid && isLoginFormValid
    }

    var isMailValid: Bool { Validators.isValidEmail(email) }

    var isPasswordValid: Bool { Validators.isStrongPassword(password) }

    var isFirstNameValid: Bool { ExampleValidationRules.validateFirstName(firstName) }

    var isLastNameValid: Bool { ExampleValidationRules.validateLastName(lastName) }

    // MARK: - Button State Management
    
    /// Updates the submit button state based on form validity
    func updateButtonState() {
        buttonState = isFormValid ? .enabled : .disabled
    }

    // MARK: - Field Validation Management
    
    /// Resets validation state for a specific field if it's currently invalid
    /// - Parameter field: The field type to reset
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

    /// Resets all field validation states to neutral
    func resetAllValidationStates() {
        emailValidationState = .neutral
        passwordValidationState = .neutral
        firstNameValidationState = .neutral
        lastNameValidationState = .neutral
    }

    /// Validates all form fields and updates their validation states
    /// - Returns: True if all fields are valid, false otherwise
    func validateAllFields() -> Bool {
        var hasErrors = false

        if !isMailValid {
            emailValidationState = .invalid
            hasErrors = true
        }

        if !isPasswordValid {
            passwordValidationState = .invalid
            hasErrors = true
        }

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

    /// Called when a field value changes - updates button state and resets field validation
    /// - Parameter field: The field that changed
    func onFieldChange(_ field: FieldType) {
        updateButtonState()
        resetFieldValidation(field)
    }

    // MARK: - Submit Handling

    /// Handles form submission - validates and performs login or account creation
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

    /// Shows validation error feedback on the button
    private func showValidationError() {
        buttonState = .error

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.updateButtonState()
        }
    }

    /// Shows authentication error feedback and resets validation states
    private func showAuthError() {
        resetAllValidationStates()
        buttonState = .error

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateButtonState()
        }
    }

    // MARK: - Authentication Methods

    /// Attempts to log in with provided credentials
    /// - Throws: AuthenticationError if validation fails or credentials are invalid
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

    /// Creates a new user account and logs in
    /// - Throws: AuthenticationError if validation fails or email is already used
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

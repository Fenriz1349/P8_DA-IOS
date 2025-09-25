//
//  AuthenticationViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import SwiftUI
import CustomTextFields

enum AuthenticationError: Error {
    case invalidCredentials
    case validationFailed
    case emailAlreadyUsed
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
            print("❌ Invalid email: \(email)")
        }

        // Validate password
        if !isPasswordValid {
            passwordValidationState = .invalid
            hasErrors = true
            print("❌ Invalid password")
        }

        // Validate creation mode fields
        if creationMode {
            if !isFirstNameValid {
                firstNameValidationState = .invalid
                hasErrors = true
                print("❌ Invalid first name: \(firstName)")
            }

            if !isLastNameValid {
                lastNameValidationState = .invalid
                hasErrors = true
                print("❌ Invalid last name: \(lastName)")
            }
        }

        return !hasErrors
    }

    // MARK: - Submit Handling
    func handleSubmit() {
        if validateAllFields() {
            Task {
                do {
                    try creationMode ? createUserAndLogin() : login()
                    print("✅ Authentication successful!")
                } catch {
                    print("❌ Auth error:", error)
                    handleAuthenticationError(error)
                    showAuthError()
                }
            }
        } else {
            print("❌ Form validation failed")
            showValidationError()
        }
    }

    private func handleAuthenticationError(_ error: Error) {
        let errorMessage: String

        if let authError = error as? AuthenticationError {
            switch authError {
            case .invalidCredentials:
                errorMessage = "Invalid email or password. Please check your credentials."
            case .validationFailed:
                errorMessage = "Please complete all required fields correctly."
            case .emailAlreadyUsed:
                errorMessage = "This email address is already registered. Please use a different email."
            }

            toastyManager?.show(message: errorMessage)
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
            print("❌ Login form validation failed")
            throw AuthenticationError.validationFailed
        }

        let users = appCoordinator.dataManager.fetchAllUsers()

        guard let user = users.first(where: { $0.email == email }),
              user.verifyPassword(password) else {
            print("❌ Email already Used: \(email)")
            throw AuthenticationError.invalidCredentials
        }

        print("✅ User found, attempting login")
        try appCoordinator.login(id: user.id)
    }

    func createUserAndLogin() throws {
        guard isCreationFormValid else {
            print("❌ Creation form validation failed")
            throw AuthenticationError.validationFailed
        }
        
        guard !appCoordinator.isEmailAlreadyUsed(email) else {
            print("❌ Invalid credentials for email: \(email)")
            throw AuthenticationError.emailAlreadyUsed
        }

        print("🔄 Attempting to create user with email: \(email)")
        try appCoordinator.dataManager.createUser(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )

        print("✅ User created successfully, attempting login")
        try login()
    }
}

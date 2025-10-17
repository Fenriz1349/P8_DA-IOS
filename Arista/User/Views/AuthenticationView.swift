//
//  AuthenticationView.swift
//  Arista
//
//  Created by Julien Cotte on 08/08/2025.
//

import SwiftUI
import CustomTextFields

struct AuthenticationView: View {
    @StateObject var viewModel: AuthenticationViewModel
    @EnvironmentObject private var toastyManager: ToastyManager

    var body: some View {
        VStack(spacing: 20) {
            if !viewModel.creationMode {
                Image("AppLogo")
                    .resizable()
                    .frame(width: 200, height: 200)
            }

            Text("welcome")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Toggle("createProfile.question", isOn: $viewModel.creationMode)

            // Email Field
            CustomTextField.triggered(
                placeholder: "mailAdress",
                text: $viewModel.email,
                type: .email,
                errorMessage: "Please enter a valid email address",
                validationState: $viewModel.emailValidationState
            )
            .onChange(of: viewModel.email) { _ in
                viewModel.updateButtonState()
                viewModel.resetFieldValidation(.email)
            }

            // Password Field
            CustomTextField.triggered(
                placeholder: "password",
                text: $viewModel.password,
                type: .password,
                errorMessage: "Password must contain 8+ characters, uppercase, number, and special character",
                validationState: $viewModel.passwordValidationState
            )
            .onChange(of: viewModel.password) { _ in
                viewModel.updateButtonState()
                viewModel.resetFieldValidation(.password)
            }

            if viewModel.creationMode {
                // First Name Field
                CustomTextField.nameField(
                    placeholder: "firstName",
                    text: $viewModel.firstName,
                    validationState: $viewModel.firstNameValidationState
                )
                .onChange(of: viewModel.firstName) { _ in
                    viewModel.updateButtonState()
                    viewModel.resetFieldValidation(.firstName)
                }

                // Last Name Field
                CustomTextField.nameField(
                    placeholder: "lastName",
                    text: $viewModel.lastName,
                    validationState: $viewModel.lastNameValidationState
                )
                .onChange(of: viewModel.lastName) { _ in
                    viewModel.updateButtonState()
                    viewModel.resetFieldValidation(.lastName)
                }
            }

            // Submit Button
            Button {
                viewModel.handleSubmit()
            } label: {
                Text(viewModel.creationMode ? "createProfile" : "login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.buttonBackgroundColor)
                    .cornerRadius(12)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.buttonState)
            }
            .padding(.horizontal)
        }.onAppear {
            viewModel.configure(toastyManager: toastyManager)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    AuthenticationView(
        viewModel: PreviewDataProvider.sampleAuthenticationViewModel
    ).environmentObject(PreviewDataProvider.sampleToastyManager)
}

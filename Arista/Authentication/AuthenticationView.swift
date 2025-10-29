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

            Text("auth.welcome.title")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Toggle("auth.createProfile.toggle", isOn: $viewModel.creationMode)

            CustomTextField.triggered(
                placeholder: "email".localized,
                text: $viewModel.email,
                type: .email,
                errorMessage: "validation.email.invalid".localized,
                validationState: $viewModel.emailValidationState
            )
            .onChange(of: viewModel.email) {
                viewModel.onFieldChange(.email)
            }

            CustomTextField.triggered(
                placeholder: "password".localized,
                text: $viewModel.password,
                type: .password,
                errorMessage: "validation.password.requirements".localized,
                validationState: $viewModel.passwordValidationState
            )
            .onChange(of: viewModel.password) {
                viewModel.onFieldChange(.password)
            }

            if viewModel.creationMode {
                CustomTextField.nameField(
                    placeholder: "firstName".localized,
                    text: $viewModel.firstName,
                    validationState: $viewModel.firstNameValidationState
                )
                .onChange(of: viewModel.firstName) {
                    viewModel.onFieldChange(.firstName)
                }

                CustomTextField.nameField(
                    placeholder: "lastName".localized,
                    text: $viewModel.lastName,
                    validationState: $viewModel.lastNameValidationState
                )
                .onChange(of: viewModel.lastName) {
                    viewModel.onFieldChange(.lastName)
                }
            }

            Button {
                viewModel.handleSubmit()
            } label: {
                Text(viewModel.creationMode ? "auth.createProfile.button" : "auth.login.button")
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

//
//  AuthenticationView.swift
//  Arista
//
//  Created by Julien Cotte on 08/08/2025.
//

import SwiftUI
import CustomLabels
import CustomTextFields

struct AuthenticationView: View {
    @StateObject var viewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("welcome")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Toggle("createProfile.question", isOn: $viewModel.creationMode)
                CustomTextField(placeholder: "mailAdress",
                                text: $viewModel.email,
                                type: .email)
                CustomTextField(placeholder: "password",
                                text: $viewModel.password,
                                type: .password)
                if viewModel.creationMode {
                    CustomTextField(placeholder: "firstName",
                                    text: $viewModel.firstName,
                                    type: .alphaNumber)
                    CustomTextField(placeholder: "lastName",
                                    text: $viewModel.lastName,
                                    type: .alphaNumber)
                }
                Button {
                    Task {
                        do {
                            try viewModel.creationMode
                            ? viewModel.createUserAndLogin()
                            : viewModel.login()
                        } catch {
                            print("❌ Auth error:", error)
                        }
                    }
                } label: {
                    viewModel.creationMode
                    ? CustomButtonLabel(message: "createProfile")
                    : CustomButtonLabel(message: "login")
                }
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1 : 0.6)
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    AuthenticationView(
        viewModel: PreviewDataProvider.sampleAuthenticationViewModel
    )
}

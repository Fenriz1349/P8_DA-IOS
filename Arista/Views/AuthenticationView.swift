//
//  AuthenticationView.swift
//  Arista
//
//  Created by Julien Cotte on 08/08/2025.
//

import SwiftUI
import CustomTextFields

struct AuthenticationView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("welcome")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                CustomTextField(placeholder: "mailAdress",
                                text: $username,
                                type: .email)
                CustomTextField(placeholder: "password",
                                text: $password,
                                type: .password)
                Button(action: {
                    Task {
                    }
                }) {
                    Text("Bouton")
//                    CustomButton(icon: nil, message: "login".localized, color: .black)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    AuthenticationView()
}

//
//  UserIdentityUpdateView.swift
//  Arista
//
//  Created by Julien Cotte on 01/12/2025.
//

import SwiftUI
import CustomTextFields

struct UserIdentityUpdateView: View {
    @ObservedObject var viewModel: UserViewModel

    init(viewModel: UserViewModel) {
        assert(viewModel.canEditIdentity)
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 16) {
                Text("user.edit.section.profile")
                    .font(.headline)

                CustomTextField(
                    placeholder: "firstName".localized,
                    text: $viewModel.firstName,
                    type: .alphaNumber
                )

                CustomTextField(
                    placeholder: "lastName".localized,
                    text: $viewModel.lastName,
                    type: .alphaNumber
                )
            }
        }
    }
}

#Preview {
    UserIdentityUpdateView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
}

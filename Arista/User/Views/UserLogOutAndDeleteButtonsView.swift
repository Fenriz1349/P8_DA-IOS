//
//  UserLogOutAndDeleteButtonsView.swift
//  Arista
//
//  Created by Julien Cotte on 01/12/2025.
//

import SwiftUI
import CustomLabels

struct UserLogOutAndDeleteButtonsView: View {
    @ObservedObject var viewModel: UserViewModel

    init(viewModel: UserViewModel) {
        assert(viewModel.canManageAccount)
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 12) {
                Button(role: .destructive) {
                    viewModel.showingResetAlert = true
                } label: {
                    CustomButtonLabel(
                        message: "user.edit.button.deleteAccount".localized,
                        color: .red
                    )
                }

            Button(role: .destructive, action: viewModel.logout) {
                CustomButtonLabel(
                    message: "user.edit.button.logout".localized,
                    color: .orange
                )
            }
        }
    }
}

#Preview {
    UserLogOutAndDeleteButtonsView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
}

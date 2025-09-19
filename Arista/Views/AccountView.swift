//
//  AccountView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CustomLabels

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                viewModel.showEditAccount = true
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()
            Text("hello")
                .font(.largeTitle)
            Text("\(viewModel.user.firstName) \(viewModel.user.lastName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
            Spacer()

            Button(action: {
                    try? viewModel.logout()
            }) {
                CustomButtonLabel(message: "logout", color: .red)
                    .frame(width: 200, height: 50)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .sheet(isPresented: $viewModel.showEditAccount) {
            if let editAccountViewModel = try? AppCoordinator.shared.makeEditAccountViewModel() {
                EditAccountView(viewModel: editAccountViewModel)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AccountView(viewModel: PreviewDataProvider.makeSampleAccountViewModel())
}

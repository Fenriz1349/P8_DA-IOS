//
//  AccountView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CustomLabels

struct UserView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Button("", systemImage: "gear") {
                viewModel.openEditModal()
            }
            .foregroundColor(.gray)
            .font(.title2)
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
            Spacer()

        }
        .padding(.horizontal)
        .sheet(isPresented: $viewModel.showEditModal) {
            EditUserView(viewModel: viewModel)
        }
    }
}

#Preview {
    UserView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

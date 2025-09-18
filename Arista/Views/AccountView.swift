//
//  AccountView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CustomLabels

struct AccountView: View {
   let viewModel: AccountViewModel

    var body: some View {
        VStack(alignment: .leading) {
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
                Task {
                    try viewModel.logout()
                }
            }) {
                CustomButtonLabel(message: "logout", color: .red)
                    .frame(width: 200, height: 50)
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    AccountView(viewModel: PreviewDataProvider.sampleAccountViewModel)
}

//
//  AccountView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AccountView: View {
//   let viewModel: AccountViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("hello")
                .font(.largeTitle)
//            Text("\(viewModel.currentUser.firstName) \(viewModel.currentUser.lastName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    AccountView()
}

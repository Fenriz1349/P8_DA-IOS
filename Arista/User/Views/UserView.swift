//
//  UserView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bonjour")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.user.firstName) \(viewModel.user.lastName)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button("", systemImage: "gear") {
                        viewModel.openEditModal()
                    }
                    .foregroundColor(.gray)
                    .font(.title2)
                }
                .padding(.horizontal)
                .padding(.top)

                VStack(spacing: 16) {
                    GoalSliderView(
                        type: .water,
                        goal: Int(viewModel.user.waterGoal),
                        current: $viewModel.currentWater
                    )

                    GoalSliderView(
                        type: .steps,
                        goal: Int(viewModel.user.stepsGoal),
                        current: $viewModel.currentSteps
                    )
                }
                .padding(.top, 8)

                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $viewModel.showEditModal) {
            EditUserView(viewModel: viewModel)
        }
    }
}

#Preview {
    UserView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

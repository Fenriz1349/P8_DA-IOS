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
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("user.greeting")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(viewModel.userDisplay.fullName)
                            .font(.title)
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
                .padding(.top, 8)

                VStack(spacing: 8) {
                    GoalSliderView(
                        type: .water,
                        goal: Int(viewModel.user.waterGoal),
                        current: $viewModel.currentWater
                    )
                    .padding(.horizontal)

                    GoalSliderView(
                        type: .steps,
                        goal: Int(viewModel.user.stepsGoal),
                        current: $viewModel.currentSteps
                    )
                    .padding(.horizontal)
                    CaloriesProgressBar(current: viewModel.todayCalories, goal: viewModel.userDisplay.calorieGoal)
                        .padding(.horizontal)
                    CaloriesBarChart(data: viewModel.lastSevenDaysCalories, goal: viewModel.userDisplay.calorieGoal)
                        .padding(.horizontal)
                    SleepMetricsModule(metrics: viewModel.sleepMetrics)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.refreshData()
        }
        .sheet(isPresented: $viewModel.showEditModal) {
            EditUserView(viewModel: viewModel)
        }
    }
}

#Preview {
    UserView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

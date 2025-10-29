import SwiftUI
import CustomTextFields
import CustomLabels

struct EditUserView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
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
                            placeholder:  "lastName".localized,
                            text: $viewModel.lastName,
                            type: .alphaNumber
                        )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("user.edit.section.dailyGoals")
                            .font(.headline)
                        GoalStepper(type: .calories, value: $viewModel.calorieGoal)
                        GoalStepper(type: .steps, value: $viewModel.stepsGoal)
                        GoalStepper(type: .sleep, value: $viewModel.sleepGoal)
                        GoalStepper(type: .water, value: $viewModel.waterGoal)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: viewModel.saveChanges) {
                            CustomButtonLabel(
                                iconLeading: "checkmark",
                                message:  "common.button.save".localized,
                                color: .blue
                            )
                        }

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
                .padding()
            }
            .navigationTitle("user.edit.navigationTitle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.button.cancel") {
                        viewModel.closeEditModal()
                    }
                }
            }
            .alert(
                "user.deleteAccount.alert.title".localized,
                isPresented: $viewModel.showingResetAlert
            ) {
                Button("common.button.cancel".localized, role: .cancel) { }
                Button("common.button.delete".localized, role: .destructive) {
                    viewModel.deleteAccount()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    EditUserView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
}

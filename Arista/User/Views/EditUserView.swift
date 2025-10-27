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
                        Text("Profil")
                            .font(.headline)

                        CustomTextField(
                            placeholder: "Prénom",
                            text: $viewModel.firstName,
                            type: .alphaNumber
                        )

                        CustomTextField(
                            placeholder: "Nom",
                            text: $viewModel.lastName,
                            type: .alphaNumber
                        )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Objectifs quotidiens")
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
                                message: "Enregistrer",
                                color: .blue
                            )
                        }

                        HStack(spacing: 12) {
                            Button(role: .destructive) {
                                viewModel.showingResetAlert = true
                            } label: {
                                CustomButtonLabel(message: "Supprimer le compte", color: .red)
                            }

                            Button(role: .destructive, action: viewModel.logout) {
                                CustomButtonLabel(message: "Déconnexion", color: .orange)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Modifier le profil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        viewModel.closeEditModal()
                    }
                }
            }
            .alert("Confirmer la suppression", isPresented: $viewModel.showingResetAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
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

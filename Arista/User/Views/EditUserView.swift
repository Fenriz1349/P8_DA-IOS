//
//  EditAccountView.swift
//  Arista
//
//  Created by Julien Cotte on 18/09/2025.
//

import SwiftUI
import CustomTextFields
import CustomLabels

struct EditUserView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                CustomTextField(
                    placeholder: "First Name",
                    text: $viewModel.firstName,
                    type: .alphaNumber
                )

                CustomTextField(
                    placeholder: "Last Name",
                    text: $viewModel.lastName,
                    type: .alphaNumber
                )

                HStack {
                    Text("Calorie Goal")
                    Spacer()
                    Picker("Calories", selection: Binding<Int>(
                        get: { Int(viewModel.calorieGoal) ?? 2000 },
                        set: { viewModel.calorieGoal = String($0) }
                    )) {
                        ForEach(1200...4000, id: \.self) { value in
                            Text("\(value) kcal").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120, height: 80)
                }

                HStack {
                    Text("Sleep Goal")
                    Spacer()
                    Picker("Sleep", selection: Binding<Int>(
                        get: { Int(viewModel.sleepGoal) ?? 480 },
                        set: { viewModel.sleepGoal = String($0) }
                    )) {
                        ForEach(Array(stride(from: 240, through: 720, by: 30)), id: \.self) { value in
                            Text("\(value/60)h \(value%60)min").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120, height: 80)
                }

                HStack {
                    Text("Water Goal")
                    Spacer()
                    Picker("Water", selection: Binding<Int>(
                        get: { Int(viewModel.waterGoal) ?? 25 },
                        set: { viewModel.waterGoal = String($0) }
                    )) {
                        ForEach(10...50, id: \.self) { value in
                            Text("\(value) dl").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 80)
                }
                
                ValidatedButton(
                    iconLeading: "checkmark",
                    title: "Enregistrer",
                    color: .blue,
                    isEnabled: true,
                    action: viewModel.saveChanges
                )
                
                HStack(spacing: 12) {
                    Button(action: viewModel.deleteAccount) {
                        CustomButtonLabel(message: "Delete Account", color: .red)
                    }
                    
                    Button(action: viewModel.logout) {
                        CustomButtonLabel(message: "logout", color: .red)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.closeEditModal()
                    }
                }
            }
        }
    }
}

#Preview {
    EditUserView(viewModel: PreviewDataProvider.makeSampleUserViewModel())
}

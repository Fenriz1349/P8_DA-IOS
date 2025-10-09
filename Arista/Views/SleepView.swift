//
//  SleepView.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import SwiftUI

struct SleepView: View {
    @ObservedObject var viewModel: SleepViewModel
    @EnvironmentObject private var toastyManager: ToastyManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Horloge Section
                SleepClockView(sleepCycle: viewModel.lastCycle, size: 200)

                // MARK: - État et Actions
                VStack(spacing: 16) {
                    currentStateSection
                    actionButtonsSection
                }
                .padding(.horizontal)

                HistorySection(cycles: viewModel.historyCycle)

            }
            .padding(.vertical)
        }
        .navigationTitle("Sommeil")
        .onAppear {
            viewModel.configureToasty(toastyManager: toastyManager)
            viewModel.loadLastCycle()
        }
        .sheet(isPresented: $viewModel.showManualEntry) {
            manualEntrySheet
        }
    }

    // MARK: - État Actuel
    private var currentStateSection: some View {
        VStack(spacing: 8) {
            switch viewModel.currentState {
            case .none:
                Text("Aucun cycle de sommeil")
                    .font(.headline)
                    .foregroundColor(.secondary)

            case .active(let cycle):
                VStack {
                    Text("Sommeil en cours")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Depuis \(cycle.dateStart.formattedTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

            case .completed(let cycle):
                VStack {
                    Text("Dernier sommeil")
                        .font(.headline)
                    HStack {
                        Text("Du \(cycle.dateStart.formattedTime)")
                        if let endDate = cycle.dateEnding {
                            Text("au \(endDate.formattedTime)")
                            Text("(\(cycle.dateStart.formattedInterval(to: endDate)))")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Boutons d'Actions
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Bouton principal (Toggle)
            mainActionButton

            // Bouton saisie manuelle
            Button("Saisie manuelle") {
                viewModel.showManualEntryMode()
            }
            .buttonStyle(.bordered)
        }
    }

    private var mainActionButton: some View {
        Button(action: mainActionButtonTapped) {
            HStack {
                Image(systemName: mainActionButtonIcon)
                Text(mainActionButtonTitle)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(mainActionButtonColor)
            .cornerRadius(12)
        }
    }

    // MARK: - Manuel Entry Sheet
    private var manualEntrySheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Heure de coucher",
                    selection: $viewModel.manualStartDate,
                    displayedComponents: [.date, .hourAndMinute]
                )

                DatePicker(
                    "Heure de réveil",
                    selection: $viewModel.manualEndDate,
                    displayedComponents: [.date, .hourAndMinute]
                )

                // Placeholder pour sélection qualité
                VStack(alignment: .leading) {
                    Text("Qualité du sommeil (optionnel)")
                    HStack {
                        Text("Qualité: Bonne")
                        Spacer()
                        Text("7/10")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.isEditingLastCycle ? "Modifier" : "Nouveau cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        viewModel.cancelManualEntry()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        if viewModel.isEditingLastCycle {
                            viewModel.saveEditedCycle()
                        } else {
                            viewModel.saveManualEntry()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Computed Properties pour le bouton principal
extension SleepView {

    private var mainActionButtonTitle: String {
        switch viewModel.currentState {
        case .none, .completed:
            return "Commencer le sommeil"
        case .active:
            return "Terminer le sommeil"
        }
    }

    private var mainActionButtonIcon: String {
        switch viewModel.currentState {
        case .none, .completed:
            return "moon.fill"
        case .active:
            return "sun.max.fill"
        }
    }

    private var mainActionButtonColor: Color {
        switch viewModel.currentState {
        case .none, .completed:
            return .blue
        case .active:
            return .orange
        }
    }

    private func mainActionButtonTapped() {
        switch viewModel.currentState {
        case .none, .completed:
            viewModel.startSleepCycleWithToggle()
        case .active:
            viewModel.endSleepCycleWithToggle()
        }
    }
}

#Preview {
    SleepView(viewModel: PreviewDataProvider.makeSleepViewModel())
        .environmentObject(PreviewDataProvider.sampleToastyManager)
}

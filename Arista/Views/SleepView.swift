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

                SleepClockView(sleepCycle: viewModel.lastCycle, size: 220)

                VStack(spacing: 16) {
                    currentStateSection
                    actionButtonsSection
                }
                .padding(.horizontal)

                HistorySection(cycles: viewModel.historyCycles)

            }
            .padding(.vertical)
        }
        .navigationTitle("Sommeil")
        .onAppear {
            viewModel.configureToasty(toastyManager: toastyManager)
            viewModel.loadLastCycle()
        }
        .sheet(isPresented: $viewModel.showManualEntry) {
            EditSleepCycleModal(viewModel: viewModel)
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
        HStack(spacing: 12) {
            mainActionButton

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

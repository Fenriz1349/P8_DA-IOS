//
//  SleepView.swift
//  Arista
//
//  Created by Julien Cotte on 26/09/2025.
//

import SwiftUI
import CustomLabels

struct SleepView: View {
    @StateObject var viewModel: SleepViewModel
    @EnvironmentObject private var toastyManager: ToastyManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SleepClockView(sleepCycle: viewModel.lastCycle)
                CurrentStateSection(currentState: viewModel.currentState)
//                if viewModel.currentState == .active {
                SleepQualityPicker(quality: $viewModel.selectedQuality)
//                }
                HStack {
                    MainSleepCycleButton(viewModel: viewModel)

                    Button(action: { viewModel.showManualEntryMode() }) {
                        CustomButtonIcon(icon: "pencil", color: .yellow)
                    }
                }
                
                HistorySection(cycles: viewModel.historyCycles)
            }
            .padding()
        }
        .navigationTitle("Sommeil")
        .onAppear {
            viewModel.configureToasty(toastyManager: toastyManager)
        }
        .sheet(isPresented: $viewModel.showManualEntry) {
            EditSleepCycleModal(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        SleepView(viewModel: PreviewDataProvider.makeSleepViewModel())
            .environmentObject(PreviewDataProvider.sampleToastyManager)
    }
}

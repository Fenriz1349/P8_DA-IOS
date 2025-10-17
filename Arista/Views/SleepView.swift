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
                SleepClockView(sleepCycle: $viewModel.lastCycle)
                CurrentStateSection(viewModel: viewModel)
                if viewModel.currentState.isActive {
                    SleepQualityPicker(quality: $viewModel.selectedQuality)
                }
                MainSleepCycleButton(viewModel: viewModel)

                HistorySection(cycles: viewModel.historyCycles)
            }
            .padding()
        }
        .navigationTitle("Sommeil")
        .onAppear {
            viewModel.reloadAllData() 
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

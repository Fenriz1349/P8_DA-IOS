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
        VStack(spacing: 20) {
            HStack {
                SleepClockView(sleepCycle: viewModel.currentCycle, size: 200)
                MainSleepCycleButton(viewModel: viewModel)
            }
            CurrentStateSection(viewModel: viewModel)
            if viewModel.currentState.isActive {
                SleepQualityPicker(quality: $viewModel.selectedQuality)
            }
            HistorySection(viewModel: viewModel)
        }
        .padding()
        .navigationTitle("Sommeil")
        .onAppear {
            viewModel.reloadAllData()
            viewModel.configureToasty(toastyManager: toastyManager)
        }
    }
}

#Preview {
    NavigationStack {
        SleepView(viewModel: PreviewSleepDataProvider.activeCycleViewModel)
            .environmentObject(PreviewDataProvider.sampleToastyManager)
    }
}

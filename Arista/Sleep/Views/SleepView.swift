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
                VStack(spacing: 10) {
                    MainSleepCycleButton(viewModel: viewModel)
                    if let currentCycle = viewModel.currentCycle {
                        Text("\(currentCycle.dateStart.formattedInterval(to: currentCycle.dateEnding ?? Date()))")
                            .font(.title3.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack {
                CurrentStateSection(viewModel: viewModel)
                if viewModel.currentState.isActive {
                    GradePicker(title: viewModel.title,
                                isInLine: false,
                                quality: $viewModel.selectedQuality)
                }
            }
            SleepHistorySection(viewModel: viewModel)
        }
        .padding()
        .onAppear {
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

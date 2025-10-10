//
//  MainSleepCycleButton.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI
import CustomLabels

struct MainSleepCycleButton: View {
    @ObservedObject var viewModel: SleepViewModel

    private var icon: String {
        switch viewModel.currentState {
        case .none, .completed: return "moon.fill"
        case .active: return "sun.max"
        }
    }

    private var title: String {
        switch viewModel.currentState {
        case .none, .completed: return "Commencer le sommeil"
        case .active: return "Terminer le sommeil"
        }
    }

    private var color: Color {
        switch viewModel.currentState {
        case .none, .completed: return .blue
        case .active: return .orange
        }
    }

    private var mainAction: () -> Void {
        switch viewModel.currentState {
        case .none, .completed: return { viewModel.startSleepCycleWithToggle() }
        case .active: return { viewModel.endSleepCycleWithToggle() }
        }
    }

    var body: some View {
        Button(action: mainAction) {
            CustomButtonLabel(iconLeading: icon, message: title, color: color)
        }
    }
}

#Preview {
    MainSleepCycleButton(viewModel: PreviewDataProvider.makeSleepViewModel())
}

//
//  SaveSleepButton.swift
//  Arista
//
//  Created by Julien Cotte on 10/10/2025.
//

import SwiftUI

struct SaveSleepButton: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SleepViewModel

    var body: some View {
        Button("Sauvegarder") {
            if viewModel.isEditingLastCycle {
                viewModel.saveEditedCycle()
            } else {
                viewModel.saveManualEntry()
            }

            dismiss()
        }
    }
}

#Preview {
    SaveSleepButton(viewModel: PreviewDataProvider.makeSleepViewModel())
}

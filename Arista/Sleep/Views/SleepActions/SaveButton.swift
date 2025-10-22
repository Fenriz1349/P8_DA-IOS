//
//  SaveButton.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import SwiftUI
import CustomLabels

struct SaveButton: View {
    var body: some View {
        CustomButtonLabel(
            iconLeading: "square.and.arrow.down",
            message: "Sauvegarder",
            color: .blue
        )
    }
}

#Preview {
    SaveButton()
}

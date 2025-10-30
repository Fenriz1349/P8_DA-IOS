//
//  SaveButton.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import SwiftUI
import CustomLabels
import CustomTextFields

struct ValidatedButton: View {
    let iconLeading: String?
    let title: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    init(
        iconLeading: String? = nil,
        title: String,
        color: Color,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) {
        self.iconLeading = iconLeading
        self.title = title
        self.color = color
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            CustomButtonLabel(
                iconLeading: iconLeading,
                message: title,
                color: color,
                isSelected: isEnabled
            )
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.3), value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        ValidatedButton(iconLeading: "checkmark", title: "Enregistrer", color: .blue, isEnabled: true, action: {})

        ValidatedButton(title: "Enregistrer", color: .gray, isEnabled: false, action: {})
    }
    .padding()
}

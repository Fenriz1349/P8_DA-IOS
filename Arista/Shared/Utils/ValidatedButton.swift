//
//  SaveButton.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import SwiftUI
import CustomLabels

struct ValidatedButton: View {
    let title: String
    let backgroundColor: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(12)
                .animation(.easeInOut(duration: 0.3), value: backgroundColor)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    SaveButton()
}

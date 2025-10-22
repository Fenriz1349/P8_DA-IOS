//
//  ExerciseTypeCard.swift
//  Arista
//
//  Created by Julien Cotte on 21/10/2025.
//

import SwiftUI

struct ExerciseTypeCard: View {
    let type: ExerciceType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : .blue)

                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
            .shadow(radius: isSelected ? 4 : 0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

#Preview {
    ExerciseTypeCard(type: .cardio, isSelected: true) {}
}

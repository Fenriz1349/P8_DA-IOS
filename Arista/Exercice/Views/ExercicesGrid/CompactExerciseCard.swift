//
//  CompactExerciseCard.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import SwiftUI

struct CompactExerciseCard: View {
    let type: ExerciceType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: type.iconName)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(8)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )

            Text(type.displayName)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundColor(.secondary)
        }
        .onTapGesture(perform: action)
        .frame(width: 60, height: 60)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    CompactExerciseCard(type: .running, isSelected: true) {}
}

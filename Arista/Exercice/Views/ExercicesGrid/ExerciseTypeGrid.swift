//
//  ExerciseTypeGrid.swift
//  Arista
//
//  Created by Julien Cotte on 21/10/2025.
//

import SwiftUI

struct ExerciseTypeGrid: View {
    @Binding var selectedType: ExerciceType

    private let columns = [
        GridItem(.adaptive(minimum: 60), spacing: 12)
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ExerciceType.allCases, id: \.self) { type in
                    CompactExerciseCard(type: type, isSelected: type == selectedType) {
                        selectedType = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ExerciseTypeGrid(selectedType: .constant(.cardio))
        .padding()
}

//
//  ExerciseHistoryRow.swift
//  Arista
//
//  Created by Julien Cotte on 21/10/2025.
//

import SwiftUI

struct ExerciseHistoryRow: View {
    let exercise: ExerciceDisplay

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Image(systemName: exercise.type.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                Text(exercise.type.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 55, height: 55)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.date.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text("\(exercise.duration) min")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                    Text("\(exercise.caloriesBurned) kcal brûlées")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            GradeLabel(grade: Grade(exercise.intensity))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ExerciseHistoryRow(
        exercise: PreviewExerciseDataProvider.randomExercice
    )
}

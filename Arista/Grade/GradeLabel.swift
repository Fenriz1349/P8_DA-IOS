//
//  SleepQualityLabel.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct GradeLabel: View {
    let grade: Grade

    var body: some View {

        ZStack {
            Circle()
                .fill(grade.color)
                .frame(width: 32, height: 32)

            Text("\(grade.value)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    GradeLabel(grade: Grade(5))
}

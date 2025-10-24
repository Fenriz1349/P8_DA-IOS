//
//  GoalBadge.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

struct GoalBadge: View {
    let progress: Double
    
    var body: some View {
        if progress >= 1.0 && progress < 1.05 {
            HStack(spacing: 4) {
                Text("💪")
                Text("Objectif atteint !")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        } else if progress >= 1.05 {
            HStack(spacing: 4) {
                Text("🎉")
                Text("Objectif dépassé !")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        } else {
            Spacer()
        }
    }
}

#Preview {
    GoalBadge(progress: 1.0)
    GoalBadge(progress: 1.2)
}

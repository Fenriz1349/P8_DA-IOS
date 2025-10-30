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
        if progress >= 1.0 && progress < 1.1 {
            HStack(spacing: 4) {
                Text("💪")
                Text("goal.badge.achieved")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        } else if progress >= 1.1 {
            HStack(spacing: 4) {
                Text("🎉")
                Text("goal.badge.exceeded")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    GoalBadge(progress: 1.0)
    GoalBadge(progress: 1.2)
}

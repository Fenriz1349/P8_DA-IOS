//
//  CaloriesProgressBar.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI

struct CaloriesProgressBar: View {
    let current: Int
    let goal: Int
    
    private var progress: Double { Double(current) / Double(goal) }
    
    private var displayProgress: Double { min(progress, 1.0) }
    
    private var fillColor: Color {
        progress > 1.0 ? .green : Color.orange.opacity(0.3)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("🔥")
                    .font(.title3)
                Text("Calories")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(current)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(progress >= 1.0 ? .green : .orange)
                Text("/ \(goal) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                GoalBadge(progress: progress)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 32)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(fillColor)
                    .frame(width: CGFloat(displayProgress) * (UIScreen.main.bounds.width - 64), height: 32)
                    .animation(.spring(), value: displayProgress)
                
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .fontWeight(.bold)
                        .foregroundColor(progress > 0.5 ? .white : .secondary)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        CaloriesProgressBar(
            current: 150,
            goal: 300
        )
        
        CaloriesProgressBar(
            current: 300,
            goal: 300
        )
        
        CaloriesProgressBar(
            current: 450,
            goal: 300
        )
    }
    .background(Color(.systemGroupedBackground))
}

//
//  GoalRow.swift
//  Arista
//
//  Created by Julien Cotte on 23/10/2025.
//

import SwiftUI

struct GoalRow: View {
    let label: String
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Slider(value: Binding(get: {
                Double(value)
            }, set: { newVal in
                value = Int(newVal)
            }), in: Double(range.lowerBound)...Double(range.upperBound), step: Double(step))
            .tint(.blue)
        }
    }
}

#Preview {
//    GoalRow()
}

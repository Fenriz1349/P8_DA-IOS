//
//  CurrentStateSection.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct CurrentStateSection: View {
    let currentState: SleepTrackingState

    var body: some View {
        VStack(spacing: 8) {
            switch currentState {
            case .none:
                Text("Aucun cycle de sommeil")
                    .font(.headline)
                    .foregroundColor(.secondary)

            case .active(let cycle):
                VStack {
                    Text("Sommeil en cours")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Depuis \(cycle.dateStart.formattedTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

            case .completed(let cycle):
                VStack {
                    Text("Dernier sommeil")
                        .font(.headline)
                    HStack {
                        Text("Du \(cycle.dateStart.formattedTime)")
                        if let endDate = cycle.dateEnding {
                            Text("au \(endDate.formattedTime)")
                            Text("(\(cycle.dateStart.formattedInterval(to: endDate)))")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    CurrentStateSection(currentState: .active(PreviewDataProvider.activeSleepCycle))
}

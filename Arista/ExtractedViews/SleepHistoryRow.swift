//
//  SleepHistoryRow.swift
//  Arista
//
//  Created by Julien Cotte on 09/10/2025.
//

import SwiftUI

struct SleepHistoryRow: View {
    let cycle: SleepCycle
    
    var body: some View {
        HStack(spacing: 12) {
            // Quality indicator
            Circle()
                .fill(qualityColor)
                .frame(width: 12, height: 12)
            
            // Sleep info
            VStack(alignment: .leading, spacing: 4) {
                Text(cycle.dateStart.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let endDate = cycle.dateEnding {
                    HStack(spacing: 4) {
                        Text("\(cycle.dateStart.formattedTime) → \(endDate.formattedTime)")
                            .font(.subheadline)
                        
                        Text("(\(cycle.dateStart.formattedInterval(to: endDate)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("En cours...")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Quality label
            Text(cycle.qualityDescription)
                .font(.caption)
                .foregroundColor(qualityColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var qualityColor: Color {
        switch cycle.sleepQuality {
        case .notRated:
            return .gray
        case .poor:
            return .red
        case .fair:
            return .orange
        case .good:
            return .green
        case .excellent:
            return .blue
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        // Excellent quality
        SleepHistoryRow(cycle: {
            let context = PreviewDataProvider.PreviewContext
            let cycle = SleepCycle(context: context)
            let now = Date()
            cycle.dateStart = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: now)!
            cycle.dateEnding = Calendar.current.date(bySettingHour: 6, minute: 45, second: 0, of: now)!.addingTimeInterval(86400)
            cycle.quality = 9
            return cycle
        }())
        
        // Poor quality
        SleepHistoryRow(cycle: {
            let context = PreviewDataProvider.PreviewContext
            let cycle = SleepCycle(context: context)
            let yesterday = Date().addingTimeInterval(-86400)
            cycle.dateStart = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: yesterday)!
            cycle.dateEnding = Calendar.current.date(bySettingHour: 5, minute: 30, second: 0, of: yesterday)!.addingTimeInterval(86400)
            cycle.quality = 2
            return cycle
        }())
        
        // Active (no end date)
        SleepHistoryRow(cycle: {
            let context = PreviewDataProvider.PreviewContext
            let cycle = SleepCycle(context: context)
            cycle.dateStart = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
            cycle.dateEnding = nil
            cycle.quality = 0
            return cycle
        }())
    }
    .padding()
}

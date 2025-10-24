//
//  CaloriesBarChart.swift
//  Arista
//
//  Created by Julien Cotte on 24/10/2025.
//

import SwiftUI
import Charts

struct CaloriesBarChart: View {
    let data: [DayCalories]
    let goal: Int

    private var maxValue: Int {
        let dataMax = data.map(\.calories).max() ?? goal
        return max(dataMax, goal) + 50
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historique 7 jours")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Chart {
                RuleMark(y: .value("Objectif", goal))
                    .foregroundStyle(.orange.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                
                ForEach(data) { day in
                    BarMark(
                        x: .value("Jour", day.dayLabel),
                        y: .value("Calories", day.calories)
                    )
                    .foregroundStyle(
                        day.calories >= goal ? Color.green.gradient : Color.orange.gradient
                    )
                    .annotation(position: .top) {
                        if day.calories > 0 {
                            Text("\(day.calories)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(day.calories >= goal ? .green : .orange)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...maxValue)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    let sampleData = [
        DayCalories(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, calories: 250),
        DayCalories(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, calories: 300),
        DayCalories(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, calories: 150),
        DayCalories(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, calories: 100),
        DayCalories(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, calories: 450),
        DayCalories(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, calories: 280),
        DayCalories(date: Date(), calories: 500)
    ]
    
    return CaloriesBarChart(data: sampleData, goal: 300)
        .background(Color(.systemGroupedBackground))
}

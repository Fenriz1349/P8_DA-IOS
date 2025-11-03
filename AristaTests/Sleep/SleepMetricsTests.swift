//
//  SleepMetricsTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 31/10/2025.
//

import XCTest
import SwiftUI
@testable import Arista

final class SleepMetricsTests: XCTestCase {
    
    // MARK: - averageHours Tests
    
    func test_averageHours_shouldConvertSecondsToHours() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800, // 8 hours in seconds
            sleepGoal: 480,
            averageQuality: 8.0
        )
        
        // When
        let hours = metrics.averageHours
        
        // Then
        XCTAssertEqual(hours, 8.0, accuracy: 0.001)
    }
    
    func test_averageHours_withPartialHours_shouldReturnDecimal() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 27000, // 7.5 hours
            sleepGoal: 480,
            averageQuality: 7.0
        )
        
        // When
        let hours = metrics.averageHours
        
        // Then
        XCTAssertEqual(hours, 7.5, accuracy: 0.001)
    }
    
    // MARK: - goalHours Tests
    
    func test_goalHours_shouldConvertMinutesToHours() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 0,
            sleepGoal: 480, // 8 hours in minutes
            averageQuality: 0
        )
        
        // When
        let hours = metrics.goalHours
        
        // Then
        XCTAssertEqual(hours, 8.0, accuracy: 0.001)
    }
    
    func test_goalHours_withPartialHours_shouldReturnDecimal() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 0,
            sleepGoal: 450, // 7.5 hours
            averageQuality: 0
        )
        
        // When
        let hours = metrics.goalHours
        
        // Then
        XCTAssertEqual(hours, 7.5, accuracy: 0.001)
    }
    
    // MARK: - progress Tests
    
    func test_progress_withGoalAchieved_shouldReturnOne() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800, // 8 hours
            sleepGoal: 480, // 8 hours
            averageQuality: 8.0
        )
        
        // When
        let progress = metrics.progress
        
        // Then
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }
    
    func test_progress_withGoalExceeded_shouldReturnOverOne() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 32400, // 9 hours
            sleepGoal: 480, // 8 hours
            averageQuality: 8.0
        )
        
        // When
        let progress = metrics.progress
        
        // Then
        XCTAssertGreaterThan(progress, 1.0)
        XCTAssertEqual(progress, 1.125, accuracy: 0.001) // 9/8
    }
    
    func test_progress_belowGoal_shouldReturnPartialProgress() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 21600, // 6 hours
            sleepGoal: 480, // 8 hours
            averageQuality: 6.0
        )
        
        // When
        let progress = metrics.progress
        
        // Then
        XCTAssertEqual(progress, 0.75, accuracy: 0.001) // 6/8
    }
    
    func test_progress_withZeroGoal_shouldReturnZero() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800,
            sleepGoal: 0,
            averageQuality: 8.0
        )
        
        // When
        let progress = metrics.progress
        
        // Then
        XCTAssertEqual(progress, 0.0)
    }
    
    // MARK: - grade Tests
    
    func test_grade_shouldReturnCorrectGrade() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800,
            sleepGoal: 480,
            averageQuality: 8.5
        )
        
        // When
        let grade = metrics.grade
        
        // Then
        XCTAssertEqual(grade, Grade(8))
    }
    
    func test_grade_withLowQuality_shouldReturnLowGrade() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800,
            sleepGoal: 480,
            averageQuality: 3.0
        )
        
        // When
        let grade = metrics.grade
        
        // Then
        XCTAssertEqual(grade, Grade(3))
    }
    
    // MARK: - statusIcon Tests
    
    func test_statusIcon_withGoalAchieved_shouldReturnStrongEmoji() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800, // 8 hours
            sleepGoal: 480, // 8 hours
            averageQuality: 8.0
        )
        
        // When
        let icon = metrics.statusIcon
        
        // Then
        XCTAssertEqual(icon, "💪")
    }
    
    func test_statusIcon_withProgressAbove85_shouldReturnHappyEmoji() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 27000, // 7.5 hours (93.75% of 8 hours)
            sleepGoal: 480,
            averageQuality: 7.0
        )
        
        // When
        let icon = metrics.statusIcon
        
        // Then
        XCTAssertEqual(icon, "😊")
    }
    
    func test_statusIcon_withProgressBelow85_shouldReturnSleepyEmoji() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 21600, // 6 hours (75% of 8 hours)
            sleepGoal: 480,
            averageQuality: 6.0
        )
        
        // When
        let icon = metrics.statusIcon
        
        // Then
        XCTAssertEqual(icon, "😴")
    }
    
    // MARK: - statusText Tests
    
    func test_statusText_withGoalAchieved_shouldReturnAchievedText() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800,
            sleepGoal: 480,
            averageQuality: 8.0
        )
        
        // When
        let text = metrics.statusText
        
        // Then
        XCTAssertEqual(text, "sleep.metrics.status.goalAchieved".localized)
    }
    
    func test_statusText_withProgressAbove85_shouldReturnCloseText() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 27000, // 7.5 hours
            sleepGoal: 480,
            averageQuality: 7.0
        )
        
        // When
        let text = metrics.statusText
        
        // Then
        XCTAssertEqual(text, "sleep.metrics.status.closeToGoal".localized)
    }
    
    func test_statusText_withProgressBelow85_shouldReturnBelowText() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 21600, // 6 hours
            sleepGoal: 480,
            averageQuality: 6.0
        )
        
        // When
        let text = metrics.statusText
        
        // Then
        XCTAssertEqual(text, "sleep.metrics.status.belowGoal".localized)
    }
    
    // MARK: - progressColor Tests
    
    func test_progressColor_withGoalAchieved_shouldReturnGreen() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800,
            sleepGoal: 480,
            averageQuality: 8.0
        )
        
        // When
        let color = metrics.progressColor
        
        // Then
        XCTAssertEqual(color, .green)
    }
    
    func test_progressColor_withProgressAbove85_shouldReturnOrange() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 27000, // 7.5 hours
            sleepGoal: 480,
            averageQuality: 7.0
        )
        
        // When
        let color = metrics.progressColor
        
        // Then
        XCTAssertEqual(color, .orange)
    }
    
    func test_progressColor_withProgressBelow85_shouldReturnRed() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 21600, // 6 hours
            sleepGoal: 480,
            averageQuality: 6.0
        )
        
        // When
        let color = metrics.progressColor
        
        // Then
        XCTAssertEqual(color, .red)
    }
    
    // MARK: - formattedAverageDuration Tests
    
    func test_formattedAverageDuration_withWholeHours_shouldReturnHoursOnly() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 28800, // 8 hours exactly
            sleepGoal: 480,
            averageQuality: 8.0
        )
        
        // When
        let formatted = metrics.formattedAverageDuration
        
        // Then
        XCTAssertEqual(formatted, "8h")
    }
    
    func test_formattedAverageDuration_withHoursAndMinutes_shouldReturnBoth() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 27900, // 7h 45min
            sleepGoal: 480,
            averageQuality: 7.0
        )
        
        // When
        let formatted = metrics.formattedAverageDuration
        
        // Then
        XCTAssertEqual(formatted, "7h45")
    }
    
    func test_formattedAverageDuration_withZero_shouldReturnZeroHours() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 0,
            sleepGoal: 480,
            averageQuality: 0
        )
        
        // When
        let formatted = metrics.formattedAverageDuration
        
        // Then
        XCTAssertEqual(formatted, "0h")
    }
    
    // MARK: - formattedGoal Tests
    
    func test_formattedGoal_withWholeHours_shouldReturnHoursOnly() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 0,
            sleepGoal: 480, // 8 hours
            averageQuality: 0
        )
        
        // When
        let formatted = metrics.formattedGoal
        
        // Then
        XCTAssertEqual(formatted, "8h")
    }
    
    func test_formattedGoal_withHoursAndMinutes_shouldReturnBoth() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 0,
            sleepGoal: 450, // 7h 30min
            averageQuality: 0
        )
        
        // When
        let formatted = metrics.formattedGoal
        
        // Then
        XCTAssertEqual(formatted, "7h30")
    }
    
    func test_formattedGoal_withZero_shouldReturnZeroHours() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 0,
            sleepGoal: 0,
            averageQuality: 0
        )
        
        // When
        let formatted = metrics.formattedGoal
        
        // Then
        XCTAssertEqual(formatted, "0h")
    }
    
    // MARK: - Integration Tests
    
    func test_allProperties_withTypicalValues_shouldWorkTogether() {
        // Given
        let metrics = SleepMetrics(
            averageDuration: 27000, // 7.5 hours
            sleepGoal: 480, // 8 hours
            averageQuality: 7.5
        )
        
        // Then
        XCTAssertEqual(metrics.averageHours, 7.5, accuracy: 0.001)
        XCTAssertEqual(metrics.goalHours, 8.0, accuracy: 0.001)
        XCTAssertEqual(metrics.progress, 0.9375, accuracy: 0.001) // 7.5/8
        XCTAssertEqual(metrics.grade, Grade(7))
        XCTAssertEqual(metrics.statusIcon, "😊") // > 0.85
        XCTAssertEqual(metrics.progressColor, .orange)
        XCTAssertEqual(metrics.formattedAverageDuration, "7h30")
        XCTAssertEqual(metrics.formattedGoal, "8h")
    }
}

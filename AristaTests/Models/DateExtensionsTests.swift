//
//  DateExtensionsTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 26/09/2025.
//

import XCTest
@testable import Arista

final class DateExtensionsTests: XCTestCase {
    
    // MARK: - validateInterval Tests
    
    func test_validateInterval_withValidDates_shouldNotThrow() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 heure plus tard
        
        // When / Then
        XCTAssertNoThrow(try Date.validateInterval(from: startDate, to: endDate))
    }
    
    func test_validateInterval_withInvalidDates_shouldThrowError() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-3600) // 1 heure avant
        
        // When / Then
        XCTAssertThrowsError(try Date.validateInterval(from: startDate, to: endDate)) { error in
            XCTAssertEqual(error as? DateValidationError, .endDateBeforeStartDate)
            XCTAssertEqual(error.localizedDescription, "L'heure de fin doit être après l'heure de début.")
        }
    }
    
    func test_validateInterval_withSameDates_shouldThrowError() {
        // Given
        let date = Date()
        
        // When / Then
        XCTAssertThrowsError(try Date.validateInterval(from: date, to: date)) { error in
            XCTAssertEqual(error as? DateValidationError, .endDateBeforeStartDate)
        }
    }
    
    func test_validateInterval_withVerySmallDifference_shouldNotThrow() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(0.001) // 1 milliseconde plus tard
        
        // When / Then
        XCTAssertNoThrow(try Date.validateInterval(from: startDate, to: endDate))
    }
    
    // MARK: - duration Tests
    
    func test_duration_withPositiveInterval_returnsCorrectDuration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 heure
        
        // When
        let duration = startDate.duration(to: endDate)
        
        // Then
        XCTAssertEqual(duration, 3600.0, accuracy: 0.001)
    }
    
    func test_duration_withNegativeInterval_returnsNegativeDuration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-1800) // 30 minutes avant
        
        // When
        let duration = startDate.duration(to: endDate)
        
        // Then
        XCTAssertEqual(duration, -1800.0, accuracy: 0.001)
    }
    
    func test_duration_withSameDates_returnsZero() {
        // Given
        let date = Date()
        
        // When
        let duration = date.duration(to: date)
        
        // Then
        XCTAssertEqual(duration, 0.0, accuracy: 0.001)
    }
    
    func test_duration_withMultipleHours_returnsCorrectDuration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(8 * 3600) // 8 heures
        
        // When
        let duration = startDate.duration(to: endDate)
        
        // Then
        XCTAssertEqual(duration, 28800.0, accuracy: 0.001) // 8 * 3600
    }
}

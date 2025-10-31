//
//  DateExtensionsTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 26/09/2025.
//

import XCTest
@testable import Arista

final class DateExtensionsTests: XCTestCase {
    
    /// validateInterval Tests
    
    func test_validateInterval_withValidDates_shouldNotThrow() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour later
        
        // When / Then
        XCTAssertNoThrow(try Date.validateInterval(from: startDate, to: endDate))
    }
    
    func test_validateInterval_withInvalidDates_shouldThrowError() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-3600) // 1 hour before
        
        // When / Then
        XCTAssertThrowsError(try Date.validateInterval(from: startDate, to: endDate)) { error in
            XCTAssertEqual(error as? DateValidationError, .endDateBeforeStartDate)
            
            XCTAssertFalse(error.localizedDescription.isEmpty)
            XCTAssertEqual(
                error.localizedDescription,
                "error.date.endDateBeforeStartDate".localized
            )
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
        let endDate = startDate.addingTimeInterval(0.001) // 1 milliseconde later
        
        // When / Then
        XCTAssertNoThrow(try Date.validateInterval(from: startDate, to: endDate))
    }
    
    /// duration Tests
    
    func test_duration_withPositiveInterval_returnsCorrectDuration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour
        
        // When
        let duration = startDate.duration(to: endDate)
        
        // Then
        XCTAssertEqual(duration, 3600.0, accuracy: 0.001)
    }
    
    func test_duration_withNegativeInterval_returnsNegativeDuration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-1800) // 30 minutes before
        
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
        let endDate = startDate.addingTimeInterval(8 * 3600) // 8 hours
        
        // When
        let duration = startDate.duration(to: endDate)
        
        // Then
        XCTAssertEqual(duration, 28800.0, accuracy: 0.001) // 8 * 3600
    }
    
    /// isSameDay Tests

    func test_isSameDay_withSameCalendarDay_returnsTrue() {
        // Given
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 22, hour: 8))!
        let date2 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 22, hour: 23))!
        
        // When
        let result = date1.isSameDay(as: date2)
        
        // Then
        XCTAssertTrue(result)
    }

    func test_isSameDay_withDifferentDays_returnsFalse() {
        // Given
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 22))!
        let date2 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 23))!
        
        // When
        let result = date1.isSameDay(as: date2)
        
        // Then
        XCTAssertFalse(result)
    }

    /// formattedInterval Tests

    func test_formattedInterval_withMinutesOnly_returnsMinutes() {
        // Given
        let start = Date()
        let end = start.addingTimeInterval(15 * 60)
        
        // When
        let result = start.formattedInterval(to: end)
        
        // Then
        XCTAssertEqual(result, "15min")
    }

    func test_formattedInterval_withHoursAndMinutes_returnsFormattedString() {
        // Given
        let start = Date()
        let end = start.addingTimeInterval((2 * 3600) + (30 * 60))
        
        // When
        let result = start.formattedInterval(to: end)
        
        // Then
        XCTAssertEqual(result, "2h 30min")
    }

    func test_formattedInterval_withExactHours_returnsHoursOnly() {
        // Given
        let start = Date()
        let end = start.addingTimeInterval(3 * 3600)
        
        // When
        let result = start.formattedInterval(to: end)
        
        // Then
        XCTAssertEqual(result, "3h")
    }

    /// formattedDate / formattedDateTime / formattedTime

    func test_formattedDate_containsWeekdayMonthAndYear() {
        // Given
        let date = Date()
        
        // When
        let formatted = date.formattedDate
        
        // Then
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains(where: { $0.isLetter }))
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        XCTAssertTrue(formatted.contains(String(year)))
    }

    func test_formattedDateTime_containsDateAndTime() {
        // Given
        let date = Date(timeIntervalSince1970: 0) // 1 janv. 1970
        let result = date.formattedDateTime
        print(result)
        
        // Then
        XCTAssertTrue(result.contains("1970"))
        XCTAssertTrue(result.contains(":00"))
    }

    func test_formattedTime_containsHoursAndMinutes() {
        // Given
        let date = Date()
        let result = date.formattedTime
        
        // Then
        XCTAssertTrue(result.contains(":"))
    }

}

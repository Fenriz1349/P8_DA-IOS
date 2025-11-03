//
//  DayCaloriesTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 31/10/2025.
//

import XCTest
@testable import Arista

final class DayCaloriesTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_init_shouldCreateInstanceWithProperties() {
        // Given
        let date = Date()
        let calories = 1500
        
        // When
        let dayCalories = DayCalories(date: date, calories: calories)
        
        // Then
        XCTAssertEqual(dayCalories.date, date)
        XCTAssertEqual(dayCalories.calories, calories)
        XCTAssertNotNil(dayCalories.id)
    }
    
    func test_id_shouldBeUnique() {
        // Given
        let date = Date()
        
        // When
        let day1 = DayCalories(date: date, calories: 1000)
        let day2 = DayCalories(date: date, calories: 1000)
        
        // Then
        XCTAssertNotEqual(day1.id, day2.id)
    }
    
    // MARK: - dayLabel Tests
    
    func test_dayLabel_shouldReturnFrenchAbbreviatedDayName() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "fr_FR")
        
        // Monday
        let monday = formatter.date(from: "2025-11-03")!
        let dayCalories = DayCalories(date: monday, calories: 1000)
        
        // When
        let label = dayCalories.dayLabel
        
        // Then
        // Should be "Lun" in French
        XCTAssertEqual(label, "Lun.")
    }
    
    func test_dayLabel_shouldBeCapitalized() {
        // Given
        let date = Date()
        let dayCalories = DayCalories(date: date, calories: 1000)
        
        // When
        let label = dayCalories.dayLabel
        
        // Then
        XCTAssertTrue(label.first?.isUppercase ?? false)
        XCTAssertFalse(label.isEmpty)
    }
    
    func test_dayLabel_withDifferentDays_shouldReturnCorrectLabels() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "fr_FR")
        
        let testDates = [
            ("2025-11-03", "Lun."),  // Monday
            ("2025-11-04", "Mar."),  // Tuesday
            ("2025-11-05", "Mer."),  // Wednesday
            ("2025-11-06", "Jeu."),  // Thursday
            ("2025-11-07", "Ven."),  // Friday
            ("2025-11-08", "Sam."),  // Saturday
            ("2025-11-09", "Dim.")   // Sunday
        ]
        
        for (dateString, expectedLabel) in testDates {
            // When
            let date = formatter.date(from: dateString)!
            let dayCalories = DayCalories(date: date, calories: 1000)
            
            // Then
            XCTAssertEqual(dayCalories.dayLabel, expectedLabel, "Failed for \(dateString)")
        }
    }
    
    // MARK: - shortDate Tests
    
    func test_shortDate_shouldReturnDayMonthFormat() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2025-11-03")!
        let dayCalories = DayCalories(date: date, calories: 1000)
        
        // When
        let shortDate = dayCalories.shortDate
        
        // Then
        XCTAssertEqual(shortDate, "03/11")
    }
    
    func test_shortDate_withFirstDayOfMonth_shouldReturnCorrectFormat() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2025-01-01")!
        let dayCalories = DayCalories(date: date, calories: 1000)
        
        // When
        let shortDate = dayCalories.shortDate
        
        // Then
        XCTAssertEqual(shortDate, "01/01")
    }
    
    func test_shortDate_withLastDayOfMonth_shouldReturnCorrectFormat() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2025-12-31")!
        let dayCalories = DayCalories(date: date, calories: 1000)
        
        // When
        let shortDate = dayCalories.shortDate
        
        // Then
        XCTAssertEqual(shortDate, "31/12")
    }
    
    func test_shortDate_shouldAlwaysHaveTwoDigits() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2025-03-05")!
        let dayCalories = DayCalories(date: date, calories: 1000)
        
        // When
        let shortDate = dayCalories.shortDate
        
        // Then
        XCTAssertEqual(shortDate, "05/03")
        XCTAssertEqual(shortDate.count, 5) // DD/MM = 5 characters
    }
    
    // MARK: - Calories Tests
    
    func test_calories_withZero_shouldStoreZero() {
        // Given
        let dayCalories = DayCalories(date: Date(), calories: 0)
        
        // When / Then
        XCTAssertEqual(dayCalories.calories, 0)
    }
    
    func test_calories_withLargeValue_shouldStoreCorrectly() {
        // Given
        let dayCalories = DayCalories(date: Date(), calories: 5000)
        
        // When / Then
        XCTAssertEqual(dayCalories.calories, 5000)
    }
    
    // MARK: - Integration Tests
    
    func test_allProperties_withTypicalDate_shouldWorkTogether() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2025-11-15")!
        let calories = 2000
        
        // When
        let dayCalories = DayCalories(date: date, calories: calories)
        
        // Then
        XCTAssertEqual(dayCalories.calories, 2000)
        XCTAssertEqual(dayCalories.dayLabel, "Sam.")
        XCTAssertEqual(dayCalories.shortDate, "15/11")
        XCTAssertNotNil(dayCalories.id)
    }
    
    func test_multipleInstances_shouldHaveIndependentProperties() {
        // Given
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date1 = formatter.date(from: "2025-11-01")!
        let date2 = formatter.date(from: "2025-11-02")!
        
        // When
        let day1 = DayCalories(date: date1, calories: 1000)
        let day2 = DayCalories(date: date2, calories: 2000)
        
        // Then
        XCTAssertNotEqual(day1.id, day2.id)
        XCTAssertNotEqual(day1.date, day2.date)
        XCTAssertNotEqual(day1.calories, day2.calories)
        XCTAssertNotEqual(day1.dayLabel, day2.dayLabel)
        XCTAssertNotEqual(day1.shortDate, day2.shortDate)
    }
}

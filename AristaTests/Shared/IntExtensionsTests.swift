//
//  IntExtensionsTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
@testable import Arista

//
//  IntExtensionsTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
@testable import Arista

final class IntExtensionsTests: XCTestCase {

    // MARK: - formattedInterval Tests
    
    func test_formattedInterval_underOneHour_returnsMinutesOnly() {
        // Given
        let duration = 45

        // When
        let result = duration.formattedInterval

        // Then
        XCTAssertEqual(result, "45 min")
    }

    func test_formattedInterval_exactHour_returnsHoursOnly() {
        // Given
        let duration = 120 // 2 hours

        // When
        let result = duration.formattedInterval

        // Then
        XCTAssertEqual(result, "2 h")
    }

    func test_formattedInterval_hoursAndMinutes_returnsFormattedString() {
        // Given
        let duration = 135 // 2 hours + 15 minutes

        // When
        let result = duration.formattedInterval

        // Then
        XCTAssertEqual(result, "2 h 15 min")
    }

    func test_formattedInterval_zeroMinutes_returnsZeroMinutes() {
        // Given
        let duration = 0

        // When
        let result = duration.formattedInterval

        // Then
        XCTAssertEqual(result, "0 min")
    }

    func test_formattedInterval_largeValue_returnsHoursAndMinutes() {
        // Given
        let duration = 600 // 10 hours

        // When
        let result = duration.formattedInterval

        // Then
        XCTAssertEqual(result, "10 h")
    }
    
    // MARK: - formatWater Tests
    
    func test_formatWater_withWholeNumber_returnsFormattedLiters() {
        // Given
        let water = 25 // 2.5 L
        
        // When
        let result = water.formatWater
        
        // Then
        XCTAssertEqual(result, "2.5 L")
    }
    
    func test_formatWater_withZero_returnsZeroLiters() {
        // Given
        let water = 0
        
        // When
        let result = water.formatWater
        
        // Then
        XCTAssertEqual(result, "0.0 L")
    }
    
    func test_formatWater_withSingleDigit_returnsDecimalLiters() {
        // Given
        let water = 5 // 0.5 L
        
        // When
        let result = water.formatWater
        
        // Then
        XCTAssertEqual(result, "0.5 L")
    }
    
    func test_formatWater_withLargeValue_returnsFormattedLiters() {
        // Given
        let water = 100 // 10.0 L
        
        // When
        let result = water.formatWater
        
        // Then
        XCTAssertEqual(result, "10.0 L")
    }
    
    func test_formatWater_withOddNumber_roundsToOneDecimal() {
        // Given
        let water = 33 // 3.3 L
        
        // When
        let result = water.formatWater
        
        // Then
        XCTAssertEqual(result, "3.3 L")
    }
    
    // MARK: - formatSteps Tests
    
    func test_formatSteps_withSmallNumber_returnsPlainNumber() {
        // Given
        let steps = 999
        
        // When
        let result = steps.formatSteps
        
        // Then
        XCTAssertEqual(result, "999")
    }
    
    func test_formatSteps_withThousands_returnsFormattedNumber() {
        // Given
        let steps = 5000
        
        // When
        let result = steps.formatSteps
        
        // Then
        // Note: Formatting depends on locale
        // Could be "5,000" (en_US) or "5 000" (fr_FR)
        XCTAssertTrue(result.contains("5"))
        XCTAssertTrue(result.contains("000"))
        XCTAssertFalse(result.isEmpty)
    }
    
    func test_formatSteps_withTenThousands_returnsFormattedNumber() {
        // Given
        let steps = 10000
        
        // When
        let result = steps.formatSteps
        
        // Then
        // Should be formatted with grouping separator
        // Could be "10,000" or "10 000" depending on locale
        XCTAssertTrue(result.contains("10"))
        XCTAssertTrue(result.contains("000"))
    }
    
    func test_formatSteps_withZero_returnsZero() {
        // Given
        let steps = 0
        
        // When
        let result = steps.formatSteps
        
        // Then
        XCTAssertEqual(result, "0")
    }
    
    func test_formatSteps_withLargeNumber_returnsFormattedNumber() {
        // Given
        let steps = 123456
        
        // When
        let result = steps.formatSteps
        
        // Then
        // Should contain the digits in some grouped format
        XCTAssertTrue(result.contains("123"))
        XCTAssertTrue(result.contains("456"))
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func test_formatWater_withNegativeValue_handlesGracefully() {
        // Given
        let water = -10
        
        // When
        let result = water.formatWater
        
        // Then
        XCTAssertEqual(result, "-1.0 L")
    }
    
    func test_formattedInterval_withOneMinute_returnsOneMinute() {
        // Given
        let duration = 1
        
        // When
        let result = duration.formattedInterval
        
        // Then
        XCTAssertEqual(result, "1 min")
    }
    
    func test_formattedInterval_withSixtyMinutes_returnsOneHour() {
        // Given
        let duration = 60
        
        // When
        let result = duration.formattedInterval
        
        // Then
        XCTAssertEqual(result, "1 h")
    }
    
    func test_formatSteps_withOne_returnsOne() {
        // Given
        let steps = 1
        
        // When
        let result = steps.formatSteps
        
        // Then
        XCTAssertEqual(result, "1")
    }
}

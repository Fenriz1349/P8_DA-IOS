//
//  IntExtensionsTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
@testable import Arista

final class IntExtensionsTests: XCTestCase {

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
}


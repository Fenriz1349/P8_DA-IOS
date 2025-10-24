//
//  ToastyTypeTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 25/09/2025.
//

import XCTest
import SwiftUI
@testable import Arista

final class ToastTypeTests: XCTestCase {

    /// Basic Properties Tests
    func testErrorTypeHasCorrectProperties() {
        // Given
        let errorType = ToastyType.error

        // When & Then
        XCTAssertEqual(errorType.color, .red)
        XCTAssertEqual(errorType.iconName, "exclamationmark.triangle.fill")
        XCTAssertEqual(errorType.timeout, 0)
    }

    func testErrorTimeoutIsZero() {
        // Given
        let errorType = ToastyType.error

        // When
        let timeout = errorType.timeout

        // Then
        XCTAssertEqual(timeout, 0, "Error toasts should not auto-dismiss")
    }

    func testErrorIconNameIsNotEmpty() {
        // Given
        let errorType = ToastyType.error

        // When
        let iconName = errorType.iconName

        // Then
        XCTAssertFalse(iconName.isEmpty, "Icon name should not be empty")
    }
}

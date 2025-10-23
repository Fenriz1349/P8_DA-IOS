//
//  GradeTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
@testable import Arista

final class GradeTests: XCTestCase {

    /// Tests that the value is correctly clamped between 0 and 10.
    func test_init_clampsValueWithinRange() {
        XCTAssertEqual(Grade(-5).value, 0)
        XCTAssertEqual(Grade(5).value, 5)
        XCTAssertEqual(Grade(15).value, 10)
    }

    /// Tests that the textual description matches the expected ranges.
    func test_description_forDifferentValues() {
        XCTAssertEqual(Grade(0).description, "Non évaluée")
        XCTAssertEqual(Grade(2).description, "Mauvaise")
        XCTAssertEqual(Grade(5).description, "Correcte")
        XCTAssertEqual(Grade(7).description, "Bonne")
        XCTAssertEqual(Grade(10).description, "Excellente")
    }

    /// Tests that the color matches the expected range mapping.
    func test_color_forDifferentValues() {
        XCTAssertEqual(Grade(0).color, .gray)
        XCTAssertEqual(Grade(3).color, .red)
        XCTAssertEqual(Grade(5).color, .orange)
        XCTAssertEqual(Grade(8).color, .green)
        XCTAssertEqual(Grade(9).color, .blue)
    }

    /// Tests that equality is based only on the numeric value.
    func test_equatable_returnsTrueForSameValue() {
        XCTAssertEqual(Grade(5), Grade(5))
        XCTAssertNotEqual(Grade(3), Grade(4))
    }
}

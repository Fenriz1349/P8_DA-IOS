//
//  GradeTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 23/10/2025.
//

import XCTest
@testable import Arista

final class GradeTests: XCTestCase {

    func test_init_clampsValueWithinRange() {
        XCTAssertEqual(Grade(-5).value, 0)
        XCTAssertEqual(Grade(5).value, 5)
        XCTAssertEqual(Grade(15).value, 10)
    }

    func test_description_forDifferentValues() {
        XCTAssertEqual(Grade(0).description, "grade.ungraded".localized)
        XCTAssertEqual(Grade(2).description, "grade.poor".localized)
        XCTAssertEqual(Grade(5).description, "grade.fair".localized)
        XCTAssertEqual(Grade(7).description, "grade.good".localized)
        XCTAssertEqual(Grade(10).description, "grade.excellent".localized)
    }

    func test_color_forDifferentValues() {
        XCTAssertEqual(Grade(0).color, .gray)
        XCTAssertEqual(Grade(3).color, .red)
        XCTAssertEqual(Grade(5).color, .orange)
        XCTAssertEqual(Grade(8).color, .green)
        XCTAssertEqual(Grade(9).color, .blue)
    }

    func test_equatable_returnsTrueForSameValue() {
        XCTAssertEqual(Grade(5), Grade(5))
        XCTAssertNotEqual(Grade(3), Grade(4))
    }
}

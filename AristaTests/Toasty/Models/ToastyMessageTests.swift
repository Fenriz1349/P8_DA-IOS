//
//  ToastyMessageTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 25/09/2025.
//

import XCTest
@testable import Arista

@MainActor
final class ToastyMessageTests: XCTestCase {
    
    // MARK: - Basic Creation Tests
    func testMessageCreationWithValidData() {
        // Given
        let type = ToastyType.error
        let message = ToastyTestHelpers.testMessage
        
        // When
        let toasty = ToastyMessage(message: message, type: type)
        
        // Then
        XCTAssertEqual(toasty.type, type)
        XCTAssertEqual(toasty.message, message)
    }
    
    func testMessageCreationWithEmptyMessage() {
        // Given
        let type = ToastyType.error
        let emptyMessage = ToastyTestHelpers.emptyMessage
        
        // When
        let toasty = ToastyMessage(message: emptyMessage, type: type)
        
        // Then
        XCTAssertEqual(toasty.type, type)
        XCTAssertEqual(toasty.message, emptyMessage)
        XCTAssertTrue(toasty.message.isEmpty)
    }

    func testMessageCreationWithLongMessage() {
        // Given
        let type = ToastyType.error
        let longMessage = ToastyTestHelpers.longMessage
        
        // When
        let toasty = ToastyMessage(message: longMessage, type: type)
        
        // Then
        XCTAssertEqual(toasty.type, type)
        XCTAssertEqual(toasty.message, longMessage)
    }
    
    // MARK: - Helper Tests
    func testSampleMessageCreation() {
        // Given & When
        let toasty = ToastyTestHelpers.createSampleMessage()
        
        // Then
        XCTAssertEqual(toasty.type, .error)
        XCTAssertEqual(toasty.message, ToastyTestHelpers.testMessage)
    }
}

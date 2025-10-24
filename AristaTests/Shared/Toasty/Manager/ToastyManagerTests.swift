//
//  ToastyManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 25/09/2025.
//

import XCTest
import Combine
@testable import Arista

@MainActor
final class ToastyManagerTests: XCTestCase {
    
    var sut: ToastyManager!
    
    override func setUp() {
        super.setUp()
        sut = ToastyTestHelpers.createManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    /// Initial State Tests
    func testInitialStateIsEmpty() {
        // Given & When & Then
        XCTAssertNil(sut.currentToast)
        XCTAssertFalse(sut.hasToast)
    }
    
    /// Show Toast Tests
    func testShowErrorSetsCurrentToast() {
        // Given
        let message = ToastyTestHelpers.testMessage
        
        // When
        sut.show(message: message)
        
        // Then
        XCTAssertNotNil(sut.currentToast)
        XCTAssertEqual(sut.currentToast?.type, .error)
        XCTAssertEqual(sut.currentToast?.message, message)
        XCTAssertTrue(sut.hasToast)
    }
    
    func testShowGenericToastSetsCurrentToast() {
        // Given
        let type = ToastyType.error
        let message = "Generic test message"
        
        // When
        sut.show(message: message, type: type)
        
        // Then
        XCTAssertNotNil(sut.currentToast)
        XCTAssertEqual(sut.currentToast?.type, type)
        XCTAssertEqual(sut.currentToast?.message, message)
        XCTAssertTrue(sut.hasToast)
    }
    
    /// Dismiss Tests
    func testDismissRemovesToast() {
        // Given
        sut.show(message: "Test message")
        XCTAssertTrue(sut.hasToast)
        
        // When
        sut.dismiss()
        
        // Then
        XCTAssertNil(sut.currentToast)
        XCTAssertFalse(sut.hasToast)
    }
    
    func testDismissWhenNoToastDoesNotCrash() {
        // Given
        XCTAssertFalse(sut.hasToast)
        
        // When & Then
        sut.dismiss()
        XCTAssertFalse(sut.hasToast)
    }
    
    /// Toast Replacement Tests
    func testNewToastReplacesExisting() {
        // Given
        let firstMessage = "First message"
        let secondMessage = "Second message"
        
        sut.show(message: firstMessage)
        XCTAssertEqual(sut.currentToast?.message, firstMessage)
        
        // When
        sut.show(message: secondMessage)
        
        // Then
        XCTAssertEqual(sut.currentToast?.message, secondMessage)
        XCTAssertNotEqual(sut.currentToast?.message, firstMessage)
        XCTAssertTrue(sut.hasToast)
    }
    
    ///State Consistency Tests
    func testHasToastPropertyIsConsistent() {
        // Initially false
        XCTAssertFalse(sut.hasToast)
        
        // After showing toast
        sut.show(message: "Test")
        XCTAssertTrue(sut.hasToast)
        
        // After dismissing
        sut.dismiss()
        XCTAssertFalse(sut.hasToast)
    }
}

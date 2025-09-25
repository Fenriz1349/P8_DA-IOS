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
    
    // MARK: - Initial State Tests
    func testInitialStateIsEmpty() {
        // Given & When & Then
        XCTAssertNil(sut.currentToast)
        XCTAssertFalse(sut.hasToast)
    }
    
    // MARK: - Show Toast Tests
    func testShowErrorSetsCurrentToast() {
        // Given
        let message = ToastyTestHelpers.testMessage
        
        // When
        sut.showError(message)
        
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
    
    func testShowEmptyMessage() {
        // Given
        let emptyMessage = ToastyTestHelpers.emptyMessage
        
        // When
        sut.showError(emptyMessage)
        
        // Then
        XCTAssertNotNil(sut.currentToast)
        XCTAssertEqual(sut.currentToast?.message, emptyMessage)
        XCTAssertTrue(sut.hasToast)
    }
    
    // MARK: - Dismiss Tests
    func testDismissRemovesToast() {
        // Given
        sut.showError("Test message")
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
        
        // When & Then (should not crash)
        sut.dismiss()
        XCTAssertFalse(sut.hasToast)
    }
    
    // MARK: - Toast Replacement Tests
    func testNewToastReplacesExisting() {
        // Given
        let firstMessage = "First message"
        let secondMessage = "Second message"
        
        sut.showError(firstMessage)
        XCTAssertEqual(sut.currentToast?.message, firstMessage)
        
        // When
        sut.showError(secondMessage)
        
        // Then
        XCTAssertEqual(sut.currentToast?.message, secondMessage)
        XCTAssertNotEqual(sut.currentToast?.message, firstMessage)
        XCTAssertTrue(sut.hasToast)
    }
    
    // MARK: - State Consistency Tests
    func testHasToastPropertyIsConsistent() {
        // Initially false
        XCTAssertFalse(sut.hasToast)
        
        // After showing toast
        sut.showError("Test")
        XCTAssertTrue(sut.hasToast)
        
        // After dismissing
        sut.dismiss()
        XCTAssertFalse(sut.hasToast)
    }
    
    // MARK: - Publisher Tests
    func testCurrentToastPublishesChanges() {
        // Given
        let expectation = XCTestExpectation(description: "Toast should publish changes")
        var publishedValues: [ToastyMessage?] = []
        
        let cancellable = sut.$currentToast
            .sink { toast in
                publishedValues.append(toast)
                if publishedValues.count == 2 {
                    expectation.fulfill()
                }
            }
        
        // When
        sut.showError("Test message")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedValues.count, 2)
        XCTAssertNil(publishedValues[0])
        XCTAssertEqual(publishedValues[1]?.message, "Test message")
        
        cancellable.cancel()
    }
}

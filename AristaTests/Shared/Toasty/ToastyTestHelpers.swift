//
//  ToastyTestHelpers.swift
//  AristaTests
//
//  Created by Julien Cotte on 25/09/2025.
//

import XCTest
@testable import Arista

@MainActor
struct ToastyTestHelpers {
    
    // MARK: - Sample Data
    static let testMessage = "This is a test error message"
    static let longMessage = "This is a very long error message that could span multiple lines in the UI"
    static let emptyMessage = ""

    // MARK: - Factory Methods
    static func createSampleMessage() -> ToastyMessage {
        return ToastyMessage(message: testMessage, type: .error)
    }

    static func createManager() -> ToastyManager {
        return ToastyManager()
    }

    static func createSpyManager() -> SpyToastyManager {
        return SpyToastyManager()
    }
}

class SpyToastyManager: ToastyManager {
    var showCallCount = 0
    var lastMessage: String?
    var lastType: ToastyType?
    
    override func show(message: String, type: ToastyType) {
        showCallCount += 1
        lastType = type
        lastMessage = message
    }
}

//
//  ToastyManager.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import SwiftUI

@MainActor
class ToastyManager: ObservableObject {
    @Published var currentToast: ToastyMessage?

    /// Displays a toast notification with a message and type
    /// - Parameters:
    ///   - message: The message to display
    ///   - type: The type of toast (default: .error)
    func show(message: String, type: ToastyType = .error) {
        currentToast = ToastyMessage(message: message, type: type)
    }

    /// Dismisses the current toast notification
    func dismiss() {
        currentToast = nil
    }

    var hasToast: Bool {
        currentToast != nil
    }

    /// Displays an error toast from an Error object
    /// If the error conforms to LocalizedError, uses its description, otherwise shows a generic message
    /// - Parameter error: The error to display
    func showError(_ error: Error) {
        let errorMessage: String

        if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription {
            errorMessage = description
        } else {
            print("⚠️ Unhandled error: \(error)")
            errorMessage = "error.unexpected".localized
        }

        show(message: errorMessage)
    }
}

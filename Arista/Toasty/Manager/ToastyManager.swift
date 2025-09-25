//
//  ToastyManager.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import SwiftUI

@MainActor
final class ToastyManager: ObservableObject {
    @Published var currentToast: ToastyMessage?

    func show(message: String, type: ToastyType) {
        currentToast = ToastyMessage(message: message, type: type)
    }

    func showError(_ message: String) {
        show(message: message, type: .error)
    }

    func dismiss() {
        currentToast = nil
    }

    var hasToast: Bool {
        currentToast != nil
    }
}

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

    func show(message: String, type: ToastyType = .error) {
        currentToast = ToastyMessage(message: message, type: type)
    }

    func dismiss() {
        currentToast = nil
    }

    var hasToast: Bool {
        currentToast != nil
    }
}

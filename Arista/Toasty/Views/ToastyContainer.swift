//
//  ToastyContainer.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import SwiftUI

struct ToastyContainer<Content: View>: View {
    @StateObject private var toastManager = ToastyManager()
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .environmentObject(toastManager)

            VStack {
                if let toast = toastManager.currentToast {
                    ErrorToastView(toast: toast) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            toastManager.dismiss()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }

                Spacer()
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: toastManager.hasToast)
            .zIndex(999)
        }
    }
}

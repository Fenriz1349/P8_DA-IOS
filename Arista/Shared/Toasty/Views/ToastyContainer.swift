//
//  ToastyContainer.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import SwiftUI

struct ToastyContainer<Content: View>: View {
    @ObservedObject var toastyManager: ToastyManager
    let content: Content

    init(toastyManager: ToastyManager, @ViewBuilder content: () -> Content) {
        self.toastyManager = toastyManager
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .environmentObject(toastyManager)

            VStack {
                if let toast = toastyManager.currentToast {
                    ErrorToastView(toast: toast) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            toastyManager.dismiss()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }

                Spacer()
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: toastyManager.hasToast)
            .zIndex(999)
        }
    }
}

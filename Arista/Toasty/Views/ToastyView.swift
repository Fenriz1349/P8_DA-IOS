//
//  ToastyView.swift
//  Arista
//
//  Created by Julien Cotte on 25/09/2025.
//

import SwiftUI

struct ErrorToastView: View {
    let toast: ToastyMessage
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.iconName)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))

            Text(toast.message)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(toast.type.color.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .onTapGesture {
            onDismiss()
        }
    }
}

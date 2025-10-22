//
//  DurationStepper.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import SwiftUI

struct DurationStepper: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...300
    var step: Int = 5
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value.formattedInterval)
                .font(.headline)
                .foregroundColor(.blue)
            Stepper("", value: $value, in: range, step: step)
                .labelsHidden()
        }
    }
}

#Preview {
    DurationStepper(title: "Durée", value: .constant(5))
}

//
//  Int+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 22/10/2025.
//

import Foundation

extension Int {
    /// Formats a duration in minutes as "X h Y min", "X h", or "Y min"
    var formattedInterval: String {
        let hours = self / 60
        let minutes = self % 60
        
        switch (hours, minutes) {
        case (0, _): return "\(minutes) min"
        case (_, 0): return "\(hours) h"
        default: return "\(hours) h \(minutes) min"
        }
    }
    
    var formatWater: String {
        String(format: "%.1f L", Double(self) / 10)
    }
    
    var formatSteps: String {
        self.formatted(.number.grouping(.automatic))
    }
}

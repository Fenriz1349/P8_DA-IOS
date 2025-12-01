//
//  BuildConfig.swift
//  Arista
//
//  Created by Julien Cotte on 01/12/2025.
//

enum BuildConfig {
    static let isDemo: Bool = {
        #if DEMO
        return true
        #else
        return false
        #endif
    }()
}

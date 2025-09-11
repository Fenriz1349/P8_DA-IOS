//
//  AuthenticationViewModel.swift
//  Arista
//
//  Created by Julien Cotte on 05/09/2025.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let appCoordinator: AppCoordinator
    
    init(appCoordinator: AppCoordinator = AppCoordinator.shared) {
        self.appCoordinator = appCoordinator
    }

}

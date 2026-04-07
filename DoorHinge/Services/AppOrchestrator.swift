//
//  AppOrchestrator.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 03/04/2026.
//

// AppOrchestrator handles app launch, 

import Foundation

@Observable
final class AppOrchestrator {
    private let networkService: NetworkService
    private let authService: AuthService
    private let appState: AppState
    
    init(networkService: NetworkService, authService: AuthService, appState: AppState) {
        self.networkService = networkService
        self.authService = authService
        self.appState = appState
    }
    
    func checkAuth() async {
        guard authService.setTokenFromKeychain() else {
            appState.authState = .neverLoggedIn
            return
        }
        
        do {
            let _ = try await networkService.get("/auth/verify")
            
            appState.authState = .authenticated
            
        } catch {
            appState.authState = .unauthenticated
        }
    }
    
    func signOut() {
        authService.signOut()
        appState.authState = .unauthenticated
    }
}


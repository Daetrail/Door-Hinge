//
//  ContentView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 30/03/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState
    @Environment(NetworkService.self) var networkService
    @Environment(AuthService.self) var authService
    @Environment(UserService.self) var userService
    @Environment(AppOrchestrator.self) var appOrchestrator
    
    var body: some View {
        Group {
            switch appState.authState {
            case .authenticated:
                MainView(appOrchestrator: appOrchestrator, userService: userService)
                    .transition(.opacity)
                
            case .unauthenticated, .neverLoggedIn:
                OnboardingView(networkService: networkService, authService: authService, appState: appState)
                    .transition(.opacity)
                
            case .unknown:
                ProgressView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.authState)
    }
}

#Preview {
    let appState = AppState()
    let networkService = NetworkService(appState: appState, baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    ContentView()
        .environment(appState)
        .environment(networkService)
        .environment(authService)
}

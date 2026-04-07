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
    
    var body: some View {
        Group {
            switch appState.authState {
            case .authenticated:
                MainView()
                
            case .unauthenticated, .neverLoggedIn:
                OnboardingView(networkService: networkService, authService: authService, appState: appState)
                
            case .unknown:
                ProgressView()
            }
        }
    }
}

#Preview {
    let appState = AppState()
    let networkService = NetworkService(baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    
    ContentView()
        .environment(appState)
        .environment(networkService)
        .environment(authService)
}

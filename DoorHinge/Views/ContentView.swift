//
//  ContentView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 30/03/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        Group {
            switch appState.authState {
            case .authenticated:
                MainView()
                
            case .unauthenticated, .neverLoggedIn:
                OnboardingView()
                
            case .unknown:
                ProgressView()
            }
        }
    }
}

#Preview {
    ContentView()
}

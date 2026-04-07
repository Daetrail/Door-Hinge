//
//  DoorHingeApp.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 30/03/2026.
//

import SwiftUI

@main
struct DoorHingeApp: App {
    @State private var appState: AppState
    @State private var networkService: NetworkService
    @State private var authService: AuthService
    @State private var appOrchestrator: AppOrchestrator
    @State private var userService: UserService
    
    init() {
        let state = AppState()
        let nService = NetworkService(baseURL: Constants.apiUrl)
        let aService = AuthService(networkService: nService)
        let aOrchestrator = AppOrchestrator(networkService: nService, authService: aService, appState: state)
        let uService = UserService(networkService: nService)
        
        _appState = .init(initialValue: state)
        _networkService = .init(initialValue: nService)
        _authService = .init(initialValue: aService)
        _appOrchestrator = .init(initialValue: aOrchestrator)
        _userService = .init(initialValue: uService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(networkService)
                .environment(authService)
                .environment(appOrchestrator)
                .environment(userService)
                .task {
                    await appOrchestrator.checkAuth()
                }
        }
    }
}

//
//  MainView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI

enum MainViewRoutes: Hashable {
    case profileView
}

struct MainView: View {
    @Environment(AppOrchestrator.self) var appOrchestrator
    @State private var profileVM: ProfileViewModel
    @State private var navigationPath = NavigationPath()
    
    init(appOrchestrator: AppOrchestrator, userService: UserService) {
        self.profileVM = ProfileViewModel(userService: userService, appOrchestrator: appOrchestrator)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Button {
                    appOrchestrator.signOut()
                } label: {
                    Text("Sign out")
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigationPath.append(MainViewRoutes.profileView)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: MainViewRoutes.self) { route in
                switch route {
                case .profileView:
                    ProfileView(vm: profileVM)
                }
            }
        }
    }
}

#Preview {
    let appState = AppState()
    let networkService = NetworkService(appState: appState, baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    let appOrchestrator = AppOrchestrator(networkService: networkService, authService: authService, appState: appState)
    let userService = UserService(networkService: networkService, appOrchestrator: appOrchestrator)
    
    MainView(appOrchestrator: appOrchestrator, userService: userService)
        .environment(appOrchestrator)
        .environment(userService)
}

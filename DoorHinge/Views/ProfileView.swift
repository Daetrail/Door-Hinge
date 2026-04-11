//
//  ProfileView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 11/04/2026.
//

import SwiftUI

struct ProfileView: View {
    @Bindable private var vm: ProfileViewModel
   
    init(vm: ProfileViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            Group {
                if let pfp = vm.profilePicture {
                    Image(uiImage: pfp)
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .frame(width: 200, height: 200)
            .clipShape(.circle)
            .task {
                await vm.loadProfilePicture()
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
    
    NavigationStack {
        ProfileView(vm: ProfileViewModel(userService: userService, appOrchestrator: appOrchestrator))
    }
}

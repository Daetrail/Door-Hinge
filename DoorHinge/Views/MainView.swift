//
//  MainView.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import SwiftUI

struct MainView: View {
    @Environment(AppOrchestrator.self) var appOrchestrator
    @Environment(UserService.self) var userService
    
    @State private var isReady = false
    @State private var userData: User?
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            if let user = userData, isReady {
                VStack {
                    Text("Hey there, \(user.firstName) \(user.lastName)")
                    
                    Text("Your gender is: \(user.gender.rawValue)")
                    Text("Your date of birth is: \(user.dateOfBirth.formatted(.dateTime.day(.twoDigits).month(.wide).year()))")
                    
                    Button {
                        appOrchestrator.signOut()
                    } label: {
                        Text("Sign out")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                }
                .navigationTitle("Main View")
                
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
            
        }
        .task {
            await getUserData()
        }
        .alert("Error", isPresented: $showError) {
            Button(role: .confirm) {
                Task {
                    await getUserData()
                }
            } label: {
                Text("Retry")
            }
            
            Button(role: .cancel) {
                
            } label: {
                Text("Dismiss")
            }
            
        } message: {
            Text(errorMessage)
        }
    }
    
    func getUserData() async {
        do {
            userData = try await userService.getUserData()
            isReady = true
        } catch let err {
            errorMessage = err.localizedDescription
            showError = true
        }
    }
}

#Preview {
    let networkService = NetworkService(baseURL: Constants.apiUrl)
    let authService = AuthService(networkService: networkService)
    let appState = AppState()
    let appOrchestrator = AppOrchestrator(networkService: networkService, authService: authService, appState: appState)
    let userService = UserService(networkService: networkService)
    
    MainView()
        .environment(appOrchestrator)
        .environment(userService)
}

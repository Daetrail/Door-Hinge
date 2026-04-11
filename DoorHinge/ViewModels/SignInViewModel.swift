//
//  SignInViewModel.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 09/04/2026.
//

import Foundation

@Observable
final class SignInViewModel {
    private let authService: AuthService
    private let appState: AppState
     
    var email = ""
    var isEmailValid = false
    
    var password = ""
    var isPasswordValid = false
    
    var isLoading = false
    var showError = false
    var errorMessage = ""
    
    init(authService: AuthService, appState: AppState) {
        self.authService = authService
        self.appState = appState
    }
    
    func signIn() async {
        do {
            guard !isLoading else {
                return
            }
            
            isLoading = true
            
            try await authService.signIn(email: email, password: password)
            
            appState.authState = .authenticated
            
            email = ""
            password = ""
            
        } catch (let err) {
            errorMessage = err.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}

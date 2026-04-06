//
//  SignUpViewModel.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

import Observation

@Observable
final class SignUpViewModel {
    private var authService: AuthService
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var password = ""
    
    var gender: Gender = .male
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    
}

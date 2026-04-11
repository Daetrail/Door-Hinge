//
//  ProfileViewModel.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 11/04/2026.
//

import Foundation
import SwiftUI

@Observable
final class ProfileViewModel {
    private let userService: UserService
    private let appOrchestrator: AppOrchestrator
    
    var profilePicture: UIImage?
    
    var showError = false
    var errorMessage = ""
    
    init(userService: UserService, appOrchestrator: AppOrchestrator) {
        self.userService = userService
        self.appOrchestrator = appOrchestrator
    }
    
    func loadProfilePicture() async {
        do {
            profilePicture = try await userService.getProfilePicture()
        } catch (let err) {
            errorMessage = err.localizedDescription
            showError = true
        }
    }
}

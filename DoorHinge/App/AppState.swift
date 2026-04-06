//
//  AppState.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 03/04/2026.
//

import Observation

@Observable
final class AppState {
    enum AuthState {
        case unknown          // App just launched, checking token in Keychain
        case authenticated    // User has a valid session
        case unauthenticated  // Token expired or invalid
        case neverLoggedIn    // No saved token — first-time user
    }

    var authState: AuthState = .unknown
}

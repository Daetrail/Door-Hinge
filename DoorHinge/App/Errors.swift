//
//  Errors.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 04/04/2026.
//

import Foundation

enum AppError: LocalizedError {
    case invalidRequest(String = "User input is malformed")
    case invalidResponse(String = "The server sent back malformed data")
    case unknownError(String = "An unknown error occurred")
    case auth(AuthError)
    case toilet(ToiletError)

    enum AuthError {
        case tokenExpired(String = "Your session has expired")
        case invalidCredentials(String = "Invalid email or password")
        case emailTaken(String = "Email is already taken")
    }

    enum ToiletError {
        case notFound(String = "Toilet not found")
        case alreadyReviewed(String = "You've already reviewed this toilet")
    }

    var errorDescription: String? {
        switch self {
        case .invalidRequest(let msg): return msg
        case .invalidResponse(let msg): return msg
        case .unknownError(let msg): return msg
        case .auth(let authError):
            switch authError {
            case .tokenExpired(let msg): return msg
            case .invalidCredentials(let msg): return msg
            case .emailTaken(let msg): return msg
            }
        case .toilet(let toiletError):
            switch toiletError {
            case .notFound(let msg): return msg
            case .alreadyReviewed(let msg): return msg
            }
        }
    }
}

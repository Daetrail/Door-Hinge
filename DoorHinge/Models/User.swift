//
//  User.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 03/04/2026.
//

import Foundation

enum Gender: Int, Codable {
    case male = 0
    case female
    case gay
    case lesbian
    case nonBinary
    case trans
}

struct User: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: Gender
    let dateOfBirth: Date
    let city: String
    let country: String
    let joinDate: Date
    let pfpURL: String?
}

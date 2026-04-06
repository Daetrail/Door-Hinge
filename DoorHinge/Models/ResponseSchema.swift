//
//  ResponseSchema.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 06/04/2026.
//

struct ResponseSchema<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
}

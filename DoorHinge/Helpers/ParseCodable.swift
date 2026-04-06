//
//  ParseCodable.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 03/04/2026.
//

import Foundation

enum ParseCodableError: LocalizedError {
    case failedToParse(String)
    
    var errorDescription: String? {
        switch self {
        case .failedToParse(let msg): return msg
        }
    }
}

func parseCodable<T: Codable>(type: T.Type, from data: Any) throws -> T {
    do {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decoded = try decoder.decode(T.self, from: jsonData)
        
        return decoded
        
    } catch {
        throw ParseCodableError.failedToParse(error.localizedDescription)
    }
}

func parseCodable<T: Codable>(type: T.Type, from data: Data) throws -> T {
    do {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decoded = try decoder.decode(T.self, from: data)
        
        return decoded
        
    } catch {
        throw ParseCodableError.failedToParse(error.localizedDescription)
    }
}

//
//  UserServce.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 04/04/2026.
//

import Foundation

@Observable
final class UserService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func getUserData() async throws -> User {
        let response = try await networkService.get("/user/me")
        
        switch response.status {
        case 200:
            let parsedData = try parseCodable(type: ResponseSchema<User>.self, from: response.data)
            
            guard let user = parsedData.data else {
                throw AppError.invalidResponse()
            }
            
            return user
            
        case 400, 401:
            throw AppError.invalidRequest()
        default:
            throw AppError.unknownError()
        }
    }
}

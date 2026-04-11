//
//  UserServce.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 04/04/2026.
//

import Foundation
import UIKit

@Observable
final class UserService {
    private let networkService: NetworkService
    private let appOrchestrator: AppOrchestrator
    
    init(networkService: NetworkService, appOrchestrator: AppOrchestrator) {
        self.networkService = networkService
        self.appOrchestrator = appOrchestrator
    }
    
    func getUserData() async throws -> User? {
        let response = try await networkService.get("/user/me")
        
        switch response.status {
        case 200:
            let parsedData = try parseCodable(type: ResponseSchema<User>.self, from: response.data)
            
            guard let user = parsedData.data else {
                throw AppError.invalidResponse()
            }
            
            return user
            
        case 401:
            appOrchestrator.signOut()
            return nil
        case 400:
            throw AppError.invalidRequest()
        default:
            throw AppError.unknownError()
        }
    }
    
    func getProfilePicture() async throws -> UIImage? {
        let response = try await networkService.get("/user/pfp")
        switch response.status {
        case 200:
            guard let image = UIImage(data: response.data) else {
                throw AppError.failedToDecodeImage()
            }
            
            return image
        case 404:
            return nil
        case 401:
            appOrchestrator.signOut()
            return nil
        case 400:
            throw AppError.invalidRequest()
        default:
            throw AppError.unknownError()
        }
    }
}

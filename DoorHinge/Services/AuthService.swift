//
//  AuthService.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 03/04/2026.
//

import Foundation



struct SignUpRequest: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let password: String
    let city: String
    let country: String
    let gender: Gender
    let dateOfBirth: Date
}

struct SignInRequest: Codable {
    let email: String
    let password: String
}

struct TokenContainer: Codable {
    let token: String
}

@Observable
final class AuthService {
    private let networkService: NetworkService
    private let userTokenService = "user_token"
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func signUp(email: String, firstName: String, lastName: String, password: String, city: String, country: String, gender: Gender, dateOfBirth: Date) async throws {
        let signUpReq = SignUpRequest(email: email, firstName: firstName, lastName: lastName, password: password, city: city, country: country, gender: gender, dateOfBirth: dateOfBirth)
        
        let response = try await networkService.post("/auth/sign-up", body: signUpReq)
            
        switch response.status {
        case 201:
            let parsedData = try parseCodable(type: ResponseSchema<TokenContainer>.self, from: response.data)
            
            guard let token = parsedData.data?.token else {
                throw AppError.invalidResponse()
            }
            
            try? KeychainHelper.standard.save(token, service: userTokenService)
            
            networkService.token = token
        case 409:
            throw AppError.auth(.emailTaken())
        case 400:
            throw AppError.invalidRequest()
        default:
            throw AppError.unknownError()
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let signInReq = SignInRequest(email: email, password: password)
        
        let response = try await networkService.post("/auth/sign-in", body: signInReq)
        
        switch response.status {
        case 201:
            let parsedData = try parseCodable(type: ResponseSchema<TokenContainer>.self, from: response.data)
            
            guard let token = parsedData.data?.token else {
                throw AppError.invalidResponse()
            }
            
            try? KeychainHelper.standard.save(token, service: userTokenService)
            
            networkService.token = token
        case 400:
            throw AppError.invalidRequest()
        default:
            throw AppError.unknownError()
        }
    }
    
    func setTokenFromKeychain() -> Bool {
        guard let token = try? KeychainHelper.standard.read(service: userTokenService, type: String.self) else {
            return false
        }
        
        networkService.token = token
        
        return true
    }
    
    func signOut() {
        networkService.token = nil
        KeychainHelper.standard.delete(service: userTokenService)
    }
}

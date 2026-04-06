//
//  NetworkService.swift
//  DoorHinge
//
//  Created by Matt Dustin Cruz on 03/04/2026.
//

import Foundation
import MultipartFormData

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct ImageData {
    let data: Data
    let filename: String
}

struct Response {
    let data: Data
    let status: Int
}

@Observable
final class NetworkService {
    let baseURL: String
    var token: String?
    
    // Leeway to adjust configuration of URLSession that we use in the future
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func get(_ path: String) async throws -> Response {
        // "nil as String?" means that the body argument will conform to the Encodable protocol
        return try await executeJSON(.get, path: path, body: nil as String?)
    }
    
    func post(_ path: String, body: some Encodable) async throws -> Response {
        return try await executeJSON(.post, path: path, body: body)
    }
    
    func post(_ path: String, body: some Encodable, imageData: ImageData) async throws -> Response {
        return try await executeFormData(.post, path, body: body, filename: imageData.filename, data: imageData.data, dataMediaType: .imageJpeg)
    }
    
    func delete(_ path: String, body: some Encodable) async throws -> Response {
        return try await executeJSON(.post, path: path, body: body)
    }
    
    func patch(_ path: String, body: some Encodable) async throws -> Response {
        return try await executeJSON(.patch, path: path, body: body)
    }
    
    func patch(_ path: String, body: some Encodable, imageData: ImageData) async throws -> Response {
        return try await executeFormData(.patch, path, body: body, filename: imageData.filename, data: imageData.data, dataMediaType: .imageJpeg)
    }
    
    private func executeJSON<B: Encodable>(_ method: HTTPMethod, path: String, body: B?) async throws -> Response {
        // Build full URL
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // If token has been set, set the Authorization header to the Bearer token
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Set the request body to be the Codable struct passed in
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        if http.statusCode >= 500 {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 401 {
            throw URLError(.userAuthenticationRequired)
        }
        
        return Response(data: data, status: http.statusCode)
    }
    
    private func executeFormData<B: Encodable>(_ method: HTTPMethod, _ path: String, body: B?, filename: String?, data: Data?, dataMediaType: MediaType) async throws -> Response {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        var jsonData: Data
        if let body {
            jsonData = try JSONEncoder().encode(body)
            
        } else {
            // Empty JSON
            jsonData = try JSONEncoder().encode("{}")
        }
        
        let boundary = Boundary.random()
        let formData = try MultipartFormData(boundary: boundary) {
            Subpart {
                ContentDisposition(name: "jsonBody")
                ContentType(mediaType: .applicationJson)
            } body: {
                jsonData
            }
            
            if let filename, let data {
                try Subpart {
                    try ContentDisposition(uncheckedName: "image", uncheckedFilename: filename)
                    ContentType(mediaType: dataMediaType)
                } body: {
                    data
                }
            }
        }
        
        var request = URLRequest(url: url, multipartFormData: formData)
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        if http.statusCode >= 500 {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 401 {
            throw URLError(.userAuthenticationRequired)
        }
        
        return Response(data: data, status: http.statusCode)
    }
}

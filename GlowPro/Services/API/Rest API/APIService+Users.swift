//
//  APIService+Users.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation

extension APIService {
    
    // MARK: - USERS

    func getUser(id: String) async throws -> GPUser {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .user("/\(id)"))
            )
            
            let result: GPUser = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getUserProfile() async throws -> GPUser {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .user("/profile"))
            )
            
            let result: GPUser = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getFirebaseTokenForUser(email: String) async throws -> String {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .user("/token/\(email)"))
            )
            
            let json: [String: String] = try parseData(data: data)
            
            if let token = json["token"] {
                return token
            }
            
            throw APIError.decodingError
            
        }
        catch {
            throw error
        }
        
    }
    
    func createUser(user: GPUser) async throws -> GPUser {
        
        let parameters: [String : Any] = [
            "name": user.name,
            "email": user.email,
            "external_id": user.externalId,
            "image_url": user.imageURL?.absoluteString,
            "birthday": user.birthday?.toISO(),
            "gender": user.gender?.rawValue,
        ]
        .compact()
        
        do {
            
            let data = try await buildRequest(
                method: .post,
                apiPath: .init(path: .user("")),
                parameters: parameters
            )
            
            let result: GPUser = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateUser(user: GPUser) async throws {
        
        let parameters: [String : Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "image_url": user.imageURL?.absoluteString,
            "birthday": user.birthday?.toISO(),
            "gender": user.gender?.rawValue,
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .user("/\(user.id)")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteUser(user: GPUser) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .user("/\(user.id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

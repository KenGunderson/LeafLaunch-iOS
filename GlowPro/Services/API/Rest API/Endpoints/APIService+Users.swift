//
//  APIService+Users.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation
import SwiftDate

extension APIService {
    
    // MARK: - USERS

    func getUser(id: String) async throws -> GPUser {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .user("\(id)"))
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
                apiPath: .init(path: .user("profile"))
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
                apiPath: .init(path: .user("token/\(email)"))
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
            "first_name": user.firstName,
            "last_name": user.lastName,
            "email": user.email,
            "phone_number": user.phoneNumber,
            "external_id": user.externalId,
            "image_url": user.imageURL?.absoluteString,
            "birthday": user.birthday?.toISO()
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
            "external_id": user.externalId,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "email": user.email,
            "phone_number": user.phoneNumber,
            "image_url": user.imageURL?.absoluteString,
            "birthday": user.birthday?.toISO(),
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .user("\(user.id)")),
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
                apiPath: .init(path: .user("\(user.id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

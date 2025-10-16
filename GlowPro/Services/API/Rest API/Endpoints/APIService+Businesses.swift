//
//  APIService+Businesses.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation
import SwiftDate

extension APIService {
    
    // MARK: - BUSINESS
    
    func getBusinesses(userId: String) async throws -> [Business] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .business("users/\(userId)"))
            )
            
            let result: [Business] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getBusiness(id: String) async throws -> Business {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .business("\(id)"))
            )
            
            let result: Business = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createBusiness(business: Business) async throws -> Business {
        
        let parameters: [String: Any] = [
            "owner_id": business.owner.id,
            "name": business.name,
            "description": business.description,
            "phone_number": business.phoneNumber,
            "email": business.email,
            "categories": business.categories,
            "subcategories": business.subcategories
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .business("")),
                parameters: parameters
            )
            
            return .DUMMY_DATA()
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateBusiness(business: Business) async throws {
        
        let parameters: [String: Any] = [
            "id": business.id,
            "owner_id": business.owner.id,
            "name": business.name,
            "description": business.description,
            "phone_number": business.phoneNumber,
            "email": business.email,
            "categories": business.categories,
            "subcategories": business.subcategories
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .business("\(business.id)")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteBusiness(id: String) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .business("\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

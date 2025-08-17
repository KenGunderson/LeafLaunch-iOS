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
    
    func getBusinesses() async throws -> [Business] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .business(""))
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
                apiPath: .init(path: .business("/\(id)"))
            )
            
            let result: Business = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createBusiness(business: Business) async throws -> Business {
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .business(""))
            )
            
            return .DUMMY_DATA()
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateBusiness(business: Business) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .business(""))
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
                apiPath: .init(path: .business("/\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

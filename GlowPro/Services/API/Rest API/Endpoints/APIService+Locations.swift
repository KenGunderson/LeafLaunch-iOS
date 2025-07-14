//
//  APIService+Locations.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation
import SwiftDate

extension APIService {
    
    // MARK: - LOCATIONS
    
    func getLocations() async throws -> [Location] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .location(""))
            )
            
            let result: [Location] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getLocations(businessId: String) async throws -> [Location] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .location(""))
            )
            
            let result: [Location] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getLocation(id: String) async throws -> Location {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .location("/\(id)"))
            )
            
            let result: Location = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteLocation(id: String) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .location("/\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

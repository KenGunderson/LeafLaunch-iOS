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
    
    func getWorkspaces() async throws -> [Workspace] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .location(""))
            )
            
            let result: [Workspace] = try parseData(data: data)
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
    
    func createLocation(location: Location) async throws -> Location {
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .location(""))
            )
            
            return .DUMMY_DATA()
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateLocation(location: Location) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .location(""))
            )
            
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

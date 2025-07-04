
//
//  APIService+Clients.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation
import SwiftDate

extension APIService {
    
    // MARK: - CLIENTS
    
    func getClients(businessId: String) async throws -> [Client] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .client(""))
            )
            
            let result: [Client] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getClients(locationId: String) async throws -> [Client] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .client(""))
            )
            
            let result: [Client] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getClients(employeeId: String) async throws -> [Client] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .client(""))
            )
            
            let result: [Client] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getClient(id: String) async throws -> Client {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .client("/\(id)"))
            )
            
            let result: Client = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteClient(id: String) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .client("/\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

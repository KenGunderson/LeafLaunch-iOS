
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
                apiPath: .init(path: .client("/business/\(businessId)"))
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
                apiPath: .init(path: .client("/location/\(locationId)"))
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
                apiPath: .init(path: .client("/employee/\(employeeId)"))
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
    
    func createClient(client: Client,
                      locationId: String) async throws {
        
        let parameters: [String: Any] = [
            "first_name": client.firstName,
            "last_name": client.lastName,
            "phone_number": client.phoneNumber,
            "email": client.email,
            "location_id": locationId,
            "date_of_birth": client.dateOfBirth?.ISO8601Format()
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .client("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateClient(client: Client) async throws {
        
        let parameters: [String: Any] = [
            "id": client.id,
            "first_name": client.firstName,
            "last_name": client.lastName,
            "phone_number": client.phoneNumber,
            "email": client.email,
            "location_id": client.locationId,
            "date_of_birth": client.dateOfBirth?.ISO8601Format()
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .client("/\(client.id)")),
                parameters: parameters
            )
            
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

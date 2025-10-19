//
//  APIService+Collage.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

extension APIService {
    
    // MARK: - COLLAGE
    
    func getCollage(businessId: String) async throws -> [Collage] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .collage("businesses/\(businessId)"))
            )
            
            let result: [Collage] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getCollage(locationId: String) async throws -> [Collage] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .collage("locations/\(locationId)"))
            )
            
            let result: [Collage] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getCollage(clientId: String) async throws -> [Collage] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .collage("clients/\(clientId)"))
            )
            
            let result: [Collage] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getCollage(id: String) async throws -> Collage {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .collage("\(id)"))
            )
            
            let result: Collage = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createCollage(collage: Collage) async throws {
        
        let parameters: [String: Any] = [
            "location_id": collage.locationId,
            "client_id": collage.clientId
        ]
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .collage("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteCollage(collageId: String) async throws {
     
        do {
            
            _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .collage("\(collageId)"))
            )
                        
        }
        catch {
            throw error
        }
        
    }
    
}

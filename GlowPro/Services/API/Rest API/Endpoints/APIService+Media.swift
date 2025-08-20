//
//  APIService+Media.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

extension APIService {
    
    // MARK: - CLIENTS
    
    func getMedia(businessId: String) async throws -> [Media] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: [Media] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getMedia(locationId: String) async throws -> [Media] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: [Media] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getMedia(clientId: String) async throws -> [Media] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: [Media] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
}

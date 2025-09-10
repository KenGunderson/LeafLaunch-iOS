//
//  APIService+Activity.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/25.
//

extension APIService {
    
    // MARK: - ACTIVITIES
    
    func getActivitiy(businessId: String) async throws -> [Activity] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("/business/\(businessId)"))
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getActivitiy(locationId: String) async throws -> [Activity] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("/location/\(locationId)"))
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getActivitiy(employeeId: String) async throws -> [Activity] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("/author/\(employeeId)"))
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getActivitiy(clientId: String) async throws -> [Activity] {
        
        let queryParameter: [String: String] = ["client_id": clientId]
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("")),
                queryParameters: queryParameter
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
}

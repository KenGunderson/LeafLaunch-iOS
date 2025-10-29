//
//  APIService+Activity.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/25.
//

extension APIService {
    
    // MARK: - ACTIVITIES
    
    func getActivitiy(businessId: String,
                      query: Query,
                      activityTypeFilters: [ActivityType]) async throws -> [Activity] {
        
        var queryParameters: [String: String] = [:]
        
        queryParameters["limit"] = "\(query.limit)"
        queryParameters["offset"] = "\(query.offset)"
        
        if !activityTypeFilters.isEmpty {
            queryParameters["filters"] = activityTypeFilters.map({ $0.rawValue }).joined(separator: ",")
        }
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("business/\(businessId)")),
                queryParameters: queryParameters
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getActivitiy(locationId: String,
                      query: Query,
                      activityTypeFilters: [ActivityType]) async throws -> [Activity] {
        
        var queryParameters: [String: String] = [:]
        
        queryParameters["limit"] = "\(query.limit)"
        queryParameters["offset"] = "\(query.offset)"
        
        if !activityTypeFilters.isEmpty {
            queryParameters["filters"] = activityTypeFilters.map({ $0.rawValue }).joined(separator: ",")
        }
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("location/\(locationId)")),
                queryParameters: queryParameters
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getActivitiy(employeeId: String,
                      query: Query,
                      activityTypeFilters: [ActivityType]) async throws -> [Activity] {
        
        var queryParameters: [String: String] = [:]
        
        queryParameters["limit"] = "\(query.limit)"
        queryParameters["offset"] = "\(query.offset)"
        
        if !activityTypeFilters.isEmpty {
            queryParameters["filters"] = activityTypeFilters.map({ $0.rawValue }).joined(separator: ",")
        }
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("author/\(employeeId)")),
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getActivitiy(clientId: String,
                      query: Query,
                      activityTypeFilters: [ActivityType]) async throws -> [Activity] {
        
        var queryParameters: [String: String] = ["client_id": clientId]
        
        queryParameters["limit"] = "\(query.limit)"
        queryParameters["offset"] = "\(query.offset)"
        
        if !activityTypeFilters.isEmpty {
            queryParameters["filters"] = activityTypeFilters.map({ $0.rawValue }).joined(separator: ",")
        }
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .activity("")),
                queryParameters: queryParameters
            )
            
            let result: [Activity] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
}

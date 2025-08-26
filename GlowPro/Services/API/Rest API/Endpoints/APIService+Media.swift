//
//  APIService+Media.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

extension APIService {
    
    // MARK: - CLIENTS
    
    func getMedia(businessId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
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
    
    func getMedia(locationId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
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
    
    func getMedia(clientId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
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
    
    func getMediaTags() async throws -> [MediaTag] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: [MediaTag] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createTag(tag: String) async throws {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: [MediaTag] = try parseData(data: data)
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteTag(mediaTagId: String) async throws {
     
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: [Media] = try parseData(data: data)
            
        }
        catch {
            throw error
        }
        
    }
    
}

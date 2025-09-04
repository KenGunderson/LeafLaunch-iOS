//
//  APIService+Media.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

extension APIService {
    
    // MARK: - MEDIA
    
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
    
    func getMedia(id: String) async throws -> Media {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            let result: Media = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func favoriteMedia(mediaId: String) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .media(""))
            )
            
            return
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteMedia(mediaId: String) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
            return
            
        }
        catch {
            throw error
        }
        
    }
    
    // MARK: - MEDIA TAGS
    
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
            
            _ = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteTag(mediaTagId: String) async throws {
     
        do {
            
            _ = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
                        
        }
        catch {
            throw error
        }
        
    }
    
    // MARK: - MEDIA TAG RELATIONS
    
    func createMediaTagForMedia(mediaId: String,
                                mediaTagId: String) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteMediaTagFromMedia(mediaId: String,
                                 mediaTagId: String) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media(""))
            )
                        
        }
        catch {
            throw error
        }
        
    }
    
}

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
        
        var queryParameters: [String : String] = [
            "order_by": sortingOption?.queryParameter
        ]
        .compact()
        
        if !tags.isEmpty {
            queryParameters["tag_ids"] = tags.map({ $0.id }).joined(separator: ",")
        }
        
        let favoritePrefix = sortingOption == .favorited ? "favorites/" : ""
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media("\(favoritePrefix)business/\(businessId)")),
                queryParameters: queryParameters
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
        
        var queryParameters: [String : String] = [
            "order_by": sortingOption?.queryParameter
        ]
        .compact()
        
        if !tags.isEmpty {
            queryParameters["tag_ids"] = tags.map({ $0.id }).joined(separator: ",")
        }
        
        let favoritePrefix = sortingOption == .favorited ? "favorites/" : ""
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media("\(favoritePrefix)location/\(locationId)")),
                queryParameters: queryParameters
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
        
        var queryParameters: [String : String] = [
            "order_by": sortingOption?.queryParameter
        ]
        .compact()
        
        if !tags.isEmpty {
            queryParameters["tag_ids"] = tags.map({ $0.id }).joined(separator: ",")
        }
        
        let favoritePrefix = sortingOption == .favorited ? "favorites/" : ""
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media("\(favoritePrefix)client/\(clientId)")),
                queryParameters: queryParameters
            )
            
            let result: [Media] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getMedia(authorId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
        var queryParameters: [String : String] = [
            "order_by": sortingOption?.queryParameter
        ]
        .compact()
        
        if !tags.isEmpty {
            queryParameters["tag_ids"] = tags.map({ $0.id }).joined(separator: ",")
        }
        
        let favoritePrefix = sortingOption == .favorited ? "favorites/" : ""
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .media("\(favoritePrefix)employee/\(authorId)")),
                queryParameters: queryParameters
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
                apiPath: .init(path: .media("\(id)"))
            )
            
            let result: Media = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func favoriteMedia(mediaId: String,
                       locationId: String) async throws {
        
        let parameters = [
            "location_id": locationId,
            "media_id": mediaId
        ]
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .mediaFavorite("")),
                parameters: parameters
            )
            
            return
            
        }
        catch {
            throw error
        }
        
    }
    
    func unfavoriteMedia(mediaId: String,
                         locationId: String) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .mediaFavorite("\(mediaId)"))
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
                method: .delete,
                apiPath: .init(path: .media("\(mediaId)"))
            )
            
            return
            
        }
        catch {
            throw error
        }
        
    }
    
    // MARK: - MEDIA TAGS
    
    func getMediaTags(businessId: String) async throws -> [MediaTag] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .mediaTags("business/\(businessId)"))
            )
            
            let result: [MediaTag] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createTag(tag: String, businessId: String) async throws {
        
        let parameters: [String: Any] = [
            "name": tag,
            "business_id": businessId
        ]
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .mediaTags("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteTag(mediaTagId: String) async throws {
     
        do {
            
            _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .mediaTags("\(mediaTagId)"))
            )
                        
        }
        catch {
            throw error
        }
        
    }
    
    // MARK: - MEDIA TAG RELATIONS
    
    func createMediaTagForMedia(mediaId: String,
                                mediaTagId: String) async throws {
        
        let parameters: [String: Any] = [
            "media_id": mediaId,
            "tag_id": mediaTagId
        ]
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .mediaTagRelations("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteMediaTagFromMedia(mediaId: String,
                                 mediaTagId: String) async throws {
        
        let queryParameters: [String: String] = [
            "media_id": mediaId,
            "tag_id": mediaTagId
        ]
        
        do {
            
            _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .mediaTagRelations("media/\(mediaId)/tag/\(mediaTagId)")),
                queryParameters: queryParameters
            )
                        
        }
        catch {
            throw error
        }
        
    }
    
}

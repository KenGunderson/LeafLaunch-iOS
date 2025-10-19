//
//  API.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import Foundation

internal enum HTTPRequestMethod: String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    
}

internal struct APIPath {
    let path: AppRoute
}

internal enum AppRoute {
    
    enum Version {
        
        case none
        case v1
        case v2
        case custom(String)
        
        var rawValue: String {
            
            switch self {
            case .none: return ""
            case .v1: return "v1"
            case .v2: return "v2"
            case .custom(let version): return version
            }
        }
        
    }
    
    case health
    case search
    
    case user(String, version: Version = .none)
    case device(String, version: Version = .none)
    case business(String, version: Version = .none)
    
    case location(String, version: Version = .none)
    case locationEmployee(String, version: Version = .none)
    
    case employedLocation(String, version: Version = .none)
    case employee(String, version: Version = .none)
    case employeeInvite(String, version: Version = .none)
    
    case client(String, version: Version = .none)
    
    case media(String, version: Version = .none)
    case mediaFavorite(String, version: Version = .none)
    case mediaTags(String, version: Version = .none)
    case mediaTagRelations(String, version: Version = .none)
    
    case collage(String, version: Version = .none)
    
    case notes(String, version: Version = .none)
    case activity(String, version: Version = .none)
    
    case uploadMedia(String, version: Version = .none)
    case featureRequest(String, version: Version = .none)
    case system(String, version: Version = .none)
    
    var category: String {
        switch self {
        case .health: return "health"
        case .search: return "search"
        case .user: return "users"
        case .device: return "devices"
        case .business: return "businesses"
        case .location: return "locations"
        case .locationEmployee: return "location-employees"
        case .employedLocation: return "employed-locations"
        case .employee: return "employees"
        case .employeeInvite: return "employee-invites"
        case .client: return "clients"
        case .media: return "media"
        case .mediaFavorite: return "media-favorites"
        case .mediaTags: return "media-tags"
        case .mediaTagRelations: return "media-tag-relations"
        case .collage: return "collages"
        case .notes: return "notes"
        case .activity: return "activities"
        case .uploadMedia: return "upload-media"
        case .featureRequest: return "feature-requests"
        case .system: return "glowpro"
        }
    }
    
    var buildURL: String {
        
        switch self {
        case .health,
             .search:
            
            return category
            
        case .user(let route, let version),
             .device(let route, let version),
             .business(let route, let version),
             .location(let route, let version),
             .locationEmployee(let route, let version),
             .employedLocation(let route, let version),
             .employee(let route, let version),
             .employeeInvite(let route, let version),
             .client(let route, let version),
             .media(let route, let version),
             .mediaFavorite(let route, let version),
             .mediaTags(let route, let version),
             .mediaTagRelations(let route, let version),
             .collage(let route, let version),
             .notes(let route, let version),
             .activity(let route, let version),
             .uploadMedia(let route, let version),
             .featureRequest(let route, let version),
             .system(let route, let version):
            
            return buildURL(
                category: category,
                route: route,
                version: version
            )
        }
        
    }
    
    private func buildURL(category: String,
                          route: String,
                          version: Version) -> String {
        
        var components: [String] = []
        
        if !version.rawValue.isEmpty {
            components.append(version.rawValue)
        }
        
        components.append(category)
        
        if !route.isEmpty {
            components.append(route)
        }
        
        return components.joined(separator: "/")
        
    }
    
}

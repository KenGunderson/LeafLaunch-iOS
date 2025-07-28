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
    
    let version: Version = .v1
    let path: AppRoute
    
}

internal enum Version {
    
    case v1
    case v2
    
}

internal enum AppRoute {
    
    case health
    case search
    case user(String)
    case device(String)
    case business(String)
    case location(String)
    case employee(String)
    case client(String)
    case system(String)
    
    var category: String {
        switch self {
        case .health: return "health"
        case .search: return "search"
        case .user: return "users"
        case .device: return "devices"
        case .business: return "businesses"
        case .location: return "locations"
        case .employee: return "employees"
        case .client: return "clients"
        case .system: return "glowpro"
        }
    }
    
    var buildURL: String {
        switch self {
        case .health: return "\(self.category)"
        case .search: return "\(self.category)"
        case .user(let path): return "\(self.category)\(path)"
        case .device(let path): return "\(self.category)\(path)"
        case .business(let path): return "\(self.category)\(path)"
        case .location(let path): return "\(self.category)\(path)"
        case .employee(let path): return "\(self.category)\(path)"
        case .client(let path): return "\(self.category)\(path)"
        case .system(let path): return "\(self.category)\(path)"
        }
    }
    
}

//
//  API.swift
//  Grimoire
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
    
    var category: String {
        switch self {
        case .health: return "health"
        case .search: return "search"
        case .user: return "users"
        case .device: return "devices"
        }
    }
    
    var buildURL: String {
        switch self {
        case .health: return "\(self.category)"
        case .search: return "\(self.category)"
        case .user(let userString): return "\(self.category)\(userString)"
        case .device(let deviceString): return "\(self.category)\(deviceString)"
        }
    }
    
}

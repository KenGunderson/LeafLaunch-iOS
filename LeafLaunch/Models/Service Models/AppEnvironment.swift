//
//  Environment.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import Foundation

enum AppEnvironment: Selectable {
    
    var id: String {
        return description
    }
        
    case custom(address: String)
    case localhost
    case development
    case production
    
    var displayName: String {
        switch self {
        case .custom(let address): return "LocalHost: \(address)"
        case .localhost: return "Localhost"
        case .development: return "Development"
        case .production: return "Production"
        }
    }
    
    var description: String {
        switch self {
        case .custom: return "Custom"
        case .localhost: return "Local"
        case .development: return "Dev"
        case .production: return "Prod"
        }
    }
    
}

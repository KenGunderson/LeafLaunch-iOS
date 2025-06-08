//
//  Environment.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import Foundation

enum AppEnvironment: Equatable, Hashable {
        
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
    
    var abbreviatedDisplayName: String {
        switch self {
        case .custom(_): return "Custom"
        case .localhost: return "Local"
        case .development: return "Dev"
        case .production: return "Prod"
        }
    }
    
}

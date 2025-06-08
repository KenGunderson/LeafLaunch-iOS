//
//  Routes.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import Foundation

protocol Navigation {
    //
}

enum Route: Navigation, Hashable, Sendable {
    
    enum Auth {
        
        case welcome
        case login
        case signup
        
    }
    
    enum DevSetting: String, CaseIterable {
        
        case components
        case userDefaults
        case routes
        case deeplinks
        case analytics
        case impersonate
        
        var displayName: String {
            switch self {
            case .components: return "Components"
            case .userDefaults: return "User Defaults"
            case .routes: return "Routes"
            case .deeplinks: return "Deeplinks"
            case .analytics: return "Analytics"
            case .impersonate: return "Impersonate"
            }
        }
        
        var icon: String {
            switch self {
            case .components: return "wrench.and.screwdriver.fill"
            case .userDefaults: return "flag.fill"
            case .routes: return "car.rear.road.lane"
            case .deeplinks: return "link.circle.fill"
            case .analytics: return "chart.line.uptrend.xyaxis"
            case .impersonate: return "person.crop.square.filled.and.at.rectangle.fill"
            }
        }
        
        var routeForDevSetting: Route {
            switch self {
            case .components: return .devSetting(.components)
            case .userDefaults: return .devSetting(.userDefaults)
            case .routes: return .devSetting(.routes)
            case .deeplinks: return .devSetting(.deeplinks)
            case .analytics: return .devSetting(.analytics)
            case .impersonate: return .devSetting(.impersonate)
            }
        }
        
    }
    
    case devSetting(DevSetting)
    case auth(Auth)
    
}

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
    
    enum Setting: String, CaseIterable {
        
        case profile
        case subscription
        case aboutUs
        case privacyPolicy
        case termsOfService
        case contactSupport
        case sendFeedback
        
        var displayName: String {
            switch self {
            case .profile: return "Update Profile"
            case .subscription: return "Manage Subscription"
            case .aboutUs: return "About Us"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .contactSupport: return "Contact Support"
            case .sendFeedback: return "Send Feedback"
            }
        }
        
        var icon: String {
            switch self {
            case .profile: return "person.fill"
            case .subscription: return "cart.fill"
            case .aboutUs: return "info.circle.fill"
            case .privacyPolicy: return "lock.shield.fill"
            case .termsOfService: return "clipboard.fill"
            case .contactSupport: return "envelope.fill"
            case .sendFeedback: return "message.fill"
            }
        }
        
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
    case setting(Setting)
    case clientList
    
}

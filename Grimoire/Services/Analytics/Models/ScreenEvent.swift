//
//  ScreenEvent.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import Foundation

indirect enum ScreenEvent: AnalyticsEvent {
    
    enum OnboardingScreen {
        
        case start
        case login
        case signUp
        case onboarding
        case permission
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .start: name = "start"
            case .login: name = "login"
            case .signUp: name = "sign_up"
            case .onboarding: name = "onboarding"
            case .permission: name = "permission"
            }
            
            return "onboarding.\(name)"
            
        }
        
    }
    
    enum MainEvent {
        
        case root
        case tabIntent(tab: Tab)
        
        var data: EventData {
            
            var eventName: String
            var properties: [String: Any]?
            
            switch self {
            case .root: eventName = "root"
            case .tabIntent(let tab):
                
                eventName = "tab_intent"
                properties = ["tab" : tab.rawValue]
             
            }
            
            return EventData(
                name: "main.\(eventName)",
                properties: properties
            )
            
        }
        
    }
    
    enum ProfileScreen {
        
        case profile(userId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .profile: name = "user_profile"
            }
            
            return "profile.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .profile(let userId): return ["user_id": userId]
            }
            
        }
        
    }
    
    enum Settings {
        
        case settings
        case profile
        case businessSettings
        case aboutUs
        case legal(context: String)
        case faq
        case featureRequest
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .profile: name = "profile"
            case .businessSettings: name = "business_settings"
            case .aboutUs: name = "about_us"
            case .legal: name = "legal"
            case .faq: name = "faq"
            case .featureRequest: name = "feature_request"
            }
            
            return "settings.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .settings: return [:]
            case .businessSettings: return [:]
            case .profile: return [:]
            case .aboutUs: return [:]
            case .legal(let context): return ["context": context]
            case .faq: return [:]
            case .featureRequest: return [:]
            }
            
        }
        
    }
    
    enum DevSettings {
        
        case settings
        case components
        case routes
        case deeplinks
        case userDefaults
        case analytics
        case impersonate
        case companyStats
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .components: name = "componenets"
            case .routes: name = "routes"
            case .deeplinks: name = "deeplinks"
            case .userDefaults: name = "user_defaults"
            case .analytics: name = "analytics"
            case .impersonate: name = "impersonate"
            case .companyStats: name = "company_stats"
            }
            
            return "dev_settings.\(name)"
            
        }
        
    }
    
    case root
    case launch
    case main(MainEvent)
    case home
    case onboarding(OnboardingScreen)
    case profile(ProfileScreen)
    case whatsNew
    case settings(Settings)
    case devSettings(DevSettings)
    
    var eventType: EventType {
        return .screen
    }
    
    var eventData: EventData {
        
        var screenName: String
        var properties: [String: Any]?
        
        switch self {
        case .root: screenName = "root"
        case .launch: screenName = "launch"
        case .main(let screen):
            
            screenName = screen.data.name
            properties = screen.data.properties 
            
        case .home: screenName = "home"
        case .onboarding(let screen): screenName = screen.screenName
        case .devSettings(let screen): screenName = screen.screenName
        case .settings(let screen): screenName = screen.screenName
        case .whatsNew: screenName = "whats_new"
        case .profile(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        }
        
        var _properties = properties ?? [:]
        _properties["screen"] = screenName
        
        return EventData(
            name: "screen_view",
            properties: _properties
        )
        
    }
    
}

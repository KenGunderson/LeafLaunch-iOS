//
//  ScreenEvent.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import Foundation

indirect enum ScreenEvent: AnalyticsEvent {
    
    enum AuthScreen {
        
        case start
        case login
        case signUp
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .start: name = "start"
            case .login: name = "login"
            case .signUp: name = "sign_up"
            }
            
            // Preserve the existing authentication analytics names.
            return "onboarding_\(name)"
            
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
                name: "main_\(eventName)",
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
            
            return "profile_\(name)"
            
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
        case legal(context: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .profile: name = "profile"
            case .businessSettings: name = "business_settings"
            case .legal: name = "legal"
            }
            
            return "settings_\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .settings: return [:]
            case .businessSettings: return [:]
            case .profile: return [:]
            case .legal(let context): return ["context": context]
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
        case companyStats
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .components: name = "components"
            case .routes: name = "routes"
            case .deeplinks: name = "deeplinks"
            case .userDefaults: name = "user_defaults"
            case .analytics: name = "analytics"
            case .companyStats: name = "company_stats"
            }
            
            return "dev_settings_\(name)"
            
        }
        
    }
    
    case root
    case launch
    case main(MainEvent)
    case home
    case customer(CustomerScreenEvent)
    case auth(AuthScreen)
    case profile(ProfileScreen)
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
        case .customer(let screen):

            screenName = screen.screenName
            properties = screen.properties

        case .auth(let screen): screenName = screen.screenName
        case .devSettings(let screen): screenName = screen.screenName
        case .settings(let screen): screenName = screen.screenName
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

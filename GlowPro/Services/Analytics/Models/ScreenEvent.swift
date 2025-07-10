//
//  ScreenEvent.swift
//  GlowPro
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
    
    enum Tab {
        
        case tab1
        case tab2
        case tab3
        case tab4
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .tab1: name = "Tab 1"
            case .tab2: name = "Tab 2"
            case .tab3: name = "Tab 3"
            case .tab4: name = "Tab 4"
            }
            
            return "tab.\(name)"
            
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
    
    enum BusinessScreen {
        
        case businessDetails(businessId: String)
        case businessEditDetails(businessId: String)
        case businessLocations(businessId: String)
        case businessLocationDetails(businessId: String, locationId: String)
        case businessEmployees(businessId: String)
        case businessEmployeeCreate(businessId: String)
        case businessEmployeeDetails(businessId: String, employeeId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .businessDetails: name = "business_details"
            case .businessEditDetails: name = "business_edit_details"
            case .businessLocations: name = "business_locations"
            case .businessLocationDetails: name = "business_locations_details"
            case .businessEmployees: name = "business_employees"
            case .businessEmployeeCreate: name = "business_employee_create"
            case .businessEmployeeDetails: name = "business_employee_details"
            }
            
            return "business.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .businessDetails(let businessId): return ["business_id": businessId]
            case .businessEditDetails(let businessId): return ["business_id": businessId]
            case .businessLocations(let businessId): return ["business_id": businessId]
                
            case .businessLocationDetails(let businessId, let locationId):
                
                return [
                    "business_id": businessId,
                    "location_id": locationId
                ]
                
            case .businessEmployees(let businessId): return ["business_id": businessId]
            case .businessEmployeeCreate(let businessId): return ["business_id": businessId]
                
            case .businessEmployeeDetails(let businessId, let employeeId):
                
                return [
                    "business_id": businessId,
                    "employee_id": employeeId
                ]
            }
            
        }
        
    }
    
    enum ClientScreen {
        
        case clientList
        case clientDetails(clientId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .clientList: name = "client_list"
            case .clientDetails: name = "client_details"
            }
            
            return "client.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .clientList: return nil
            case .clientDetails(let clientId): return ["client_id": clientId]
            }
            
        }
        
    }
    
    enum Settings {
        
        case settings
        case profile
        case legal(context: String)
        case faq
        case featureRequest
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .profile: name = "profile"
            case .legal: name = "legal"
            case .faq: name = "faq"
            case .featureRequest: name = "feature_request"
            }
            
            return "settings.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .settings: return [:]
            case .profile: return [:]
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
            }
            
            return "dev_settings.\(name)"
            
        }
        
    }
    
    case root
    case launch
    case main
    case onboarding(OnboardingScreen)
    case tab(Tab)
    case business(BusinessScreen)
    case client(ClientScreen)
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
        case .main: screenName = "main"
        case .onboarding(let screen): screenName = screen.screenName
        case .tab(let screen): screenName = screen.screenName
        case .business(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        case .client(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
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

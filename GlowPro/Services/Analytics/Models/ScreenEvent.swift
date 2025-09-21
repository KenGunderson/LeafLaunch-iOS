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
        
        case businessHome(businessId: String)
        case businessDetails(businessId: String)
        case businessCreateEdit(businessId: String?)
        case businessLocationList(businessId: String)
        case businessLocationCreateEdit(businessId: String, locationId: String?)
        case businessLocationHome(locationId: String)
        case businessEmployees(context: BusinessEmployeesViewModel.Context)
        case businessEmployeeInvite(businessId: String)
        case businessEmployeeInviteList(context: BusinessEmployeeInviteListViewModel.Context)
        case businessEmployeeJoin
        case businessEmployeeUpdate(businessId: String, employeeId: String)
        case businessEmployeeDetails(businessId: String, employeeId: String)
        
        case businessActivityList(context: BusinessActivityListViewModel.Context)
        case businessSecurityPinInput(businessId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .businessHome: name = "business_home"
            case .businessDetails: name = "business_details"
            case .businessCreateEdit: name = "business_edit_details"
            case .businessLocationList: name = "business_locations"
            case .businessLocationCreateEdit: name = "business_location_create_edit"
            case .businessLocationHome: name = "business_location_home"
            case .businessEmployees: name = "business_employees"
            case .businessEmployeeInvite: name = "business_employee_invite"
            case .businessEmployeeInviteList: name = "business_employee_invite_list"
            case .businessEmployeeJoin: name = "business_employee_join"
            case .businessEmployeeUpdate: name = "business_employee_update"
            case .businessEmployeeDetails: name = "business_employee_details"
            case .businessActivityList: name = "business_activity_list"
            case .businessSecurityPinInput: name = "business_security_pin_input"
            }
            
            return "business.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .businessHome(let businessId): return ["business_id": businessId]
            case .businessDetails(let businessId): return ["business_id": businessId]
            case .businessCreateEdit(let businessId):
                
                let context = (businessId == nil) ? "create" : "edit"
                return [
                    "business_id": businessId,
                    "context": context
                ]
                .compact()
                
            case .businessLocationList(let businessId): return ["business_id": businessId]
            case .businessLocationCreateEdit(let businessId, let locationId):
                
                let context = (locationId == nil) ? "create" : "edit"
                return [
                    "business_id": businessId,
                    "location_id": locationId,
                    "context": context
                ]
                .compact()
                
            case .businessLocationHome(let locationId): return ["location_id": locationId]
            case .businessEmployees(let context):
                
                return [
                    "context": context.analyticsName,
                    "id": context.analyticsId
                ]
                
            case .businessEmployeeInvite(let businessId): return ["business_id": businessId]
            case .businessEmployeeInviteList(let businessId): return ["business_id": businessId]
            case .businessEmployeeJoin: return nil
            case .businessEmployeeUpdate(let businessId, let employeeId):
                
                return [
                    "business_id": businessId,
                    "employee_id": employeeId
                ]
                
            case .businessEmployeeDetails(let businessId, let employeeId):
                
                return [
                    "business_id": businessId,
                    "employee_id": employeeId
                ]
                
            case .businessActivityList(let context):
                
                return [
                    "id": context.identifier,
                    "context": context.analyticsName
                ]
                .compact()
                
            case .businessSecurityPinInput(let businessId): return ["business_id": businessId]
            }
            
        }
        
    }
    
    enum ClientScreen {
        
        case clientList
        case clientCreateEdit(clientId: String?)
        case clientHome(clientId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .clientList: name = "client_list"
            case .clientCreateEdit: name = "client_create_edit"
            case .clientHome: name = "client_home"
            }
            
            return "client.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .clientList: return nil
            case .clientCreateEdit(let clientId):
                
                let context = (clientId == nil) ? "create" : "edit"
                return [
                    "client_id": clientId,
                    "context": context
                ]
                .compact()
                
            case .clientHome(let clientId): return ["client_id": clientId]
            }
            
        }
        
    }
    
    enum MediaScreen {
        
        case gallery
        case camera
        case preview
        case photoEdit
        case mediaTags
        case mediaReview
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .gallery: name = "gallery"
            case .camera: name = "camera"
            case .preview: name = "preview"
            case .photoEdit: name = "photo_edit"
            case .mediaTags: name = "media_tags"
            case .mediaReview: name = "media_review"
            }
            
            return "media.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .gallery: return nil
            case .camera: return nil
            case .preview: return nil
            case .photoEdit: return nil
            case .mediaTags: return nil
            case .mediaReview: return nil
            }
            
        }
        
    }
    
    enum NoteScreen {
        
        case noteList(clientId: String)
        
        case createEdit(context: NoteCreateEditViewModel.Context,
                        clientId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .noteList: name = "list"
            case .createEdit: name = "create_edit"
            }
            
            return "note.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .noteList(let clientId): return ["client_id": clientId]
            case .createEdit(let context, let clientId):
                
                switch context {
                case .create: return [
                    "context": "create",
                    "client_id": clientId
                ]
                    
                case .update(let noteId):
                    
                    return [
                        "context": "update",
                        "note_id": noteId,
                        "client_id": clientId
                    ]
                }
                
            }
            
        }
        
    }
    
    enum Settings {
        
        case settings
        case profile
        case security
        case aboutUs
        case legal(context: String)
        case faq
        case featureRequest
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .profile: name = "profile"
            case .security: name = "security"
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
            case .security: return [:]
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
    case home
    case onboarding(OnboardingScreen)
    case business(BusinessScreen)
    case client(ClientScreen)
    case media(MediaScreen)
    case profile(ProfileScreen)
    case note(NoteScreen)
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
        case .home: screenName = "home"
        case .onboarding(let screen): screenName = screen.screenName
        case .business(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        case .client(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        case .media(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        case .note(let screen):
            
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

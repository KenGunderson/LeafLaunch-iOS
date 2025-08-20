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
    
    enum Onboarding: Hashable {
        
        case welcome
        case captureProgress
        case compareResults
        case shareGrow
        case permission
        
    }
    
    enum Business: Hashable {
        
        case businessHome(businessId: String)
        case businessDetails(businessId: String)
        case businessCreateEdit(businessId: String?)
        
        case businessLocationHome(locationId: String)
        case businessLocationList(businessId: String)
        
        case businessLocationCreateEdit(businessId: String,
                                        locationId: String? = nil)
        
        case businessLocationDetails(businessId: String, locationId: String)
        
        case businessEmployees(businessId: String,
                               context: BusinessEmployeesViewModel.Context)
        
        case businessEmployeesInvite(businessId: String)
        case businessEmployeeInviteList(context: BusinessEmployeeInviteListViewModel.Context)
        case businessEmployeesUpdate(businessId: String, employeeId: String)
        case businessEmployeeDetails(businessId: String, employeeId: String)
        
    }
    
    enum Client: Hashable {
        
        case clientCreate(locationId: String?,
                          clientId: String? = nil)
        case clientList(context: ClientListViewModel.Context)
        
        
    }
    
    enum Media: Hashable {
        
        case gallery
        
    }
    
    enum Setting: String, CaseIterable {
        
        case profile
        case subscription
        case aboutUs
        case frequentlyAskedQuestions
        case contactSupport
        case sendFeedback
        case privacyPolicy
        case termsOfService
        case logout
        
        var displayName: String {
            switch self {
            case .profile: return "Update Profile"
            case .subscription: return "Manage Subscription"
            case .aboutUs: return "About Us"
            case .frequentlyAskedQuestions: return "Frequently Asked Questions"
            case .contactSupport: return "Contact Support"
            case .sendFeedback: return "Send Feedback"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .logout: return "Logout"
            }
        }
        
        var icon: String {
            switch self {
            case .profile: return "person.fill"
            case .subscription: return "cart.fill"
            case .aboutUs: return "info.circle.fill"
            case .frequentlyAskedQuestions: return "questionmark.circle.fill"
            case .contactSupport: return "envelope.fill"
            case .sendFeedback: return "message.fill"
            case .privacyPolicy: return "lock.shield.fill"
            case .termsOfService: return "clipboard.fill"
            case .logout: return "xmark.circle.fill"
            }
        }
        
        var tintColor: ColorSource {
            switch self {
            case .logout: Style.shared.background(.error)
            default: Style.shared.accent
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
    case onboarding(Onboarding)
    case setting(Setting)
    case business(Business)
    case client(Client)
    case media(Media)
    
}

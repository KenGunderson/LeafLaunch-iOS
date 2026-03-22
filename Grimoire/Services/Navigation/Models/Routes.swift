//
//  Routes.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import UIKit

protocol Navigation {
    //
}

enum Route: Navigation, Hashable, Sendable {
    
    enum AuthRoute {
        
        case welcome
        case login
        case signup
        
    }
    
    enum OnboardingRoute: Hashable {
        
        case businessSetup
        case locationControl
        case photos
        case beforeAndAfter
        case documentation
        case permission
        
    }
    
    enum SettingRoute: String, CaseIterable {
        
        case profile
        case updatePermissions
        case aboutUs
        case frequentlyAskedQuestions
        case contactSupport
        case featureRequest
        case rateApp
        case privacyPolicy
        case termsOfService
        case logout
        
        var displayName: String {
            switch self {
            case .profile: return "Update Profile"
            case .updatePermissions: return "Update Permissions"
            case .aboutUs: return "About Us"
            case .frequentlyAskedQuestions: return "Frequently Asked Questions"
            case .contactSupport: return "Contact Support"
            case .featureRequest: return "Feature Request"
            case .rateApp: return "Rate Our App"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .logout: return "Logout"
            }
        }
        
        var icon: ImageSource {
            switch self {
            case .profile: return .image(.iconPerson)
            case .updatePermissions: return .systemImage("shield.fill")
            case .aboutUs: return .image(.iconInfoCircle)
            case .frequentlyAskedQuestions: return .image(.iconQuestionMark)
            case .contactSupport: return .image(.iconMail)
            case .featureRequest: return .systemImage("lightbulb.fill")
            case .rateApp: return .systemImage("star.fill")
            case .privacyPolicy: return .image(.iconLock)
            case .termsOfService: return .systemImage("clipboard.fill")
            case .logout: return .image(.iconCloseCircle)
            }
        }
        
        var tintColor: ColorSource {
            switch self {
            case .logout: Style.shared.background(.error)
            default: Style.shared.accent
            }
        }
        
        var category: String {
            switch self {
            case .profile, .updatePermissions: return "Account"
            case .aboutUs, .frequentlyAskedQuestions, .contactSupport, .featureRequest, .rateApp: return "Help & Feedback"
            case .privacyPolicy, .termsOfService: return "Legal"
            case .logout: return "Logout"
            }
        }
        
    }
    
    enum DevSettingRoute: String, CaseIterable {
        
        case userDefaults
        case routes
        case deeplinks
        case analytics
        case impersonate
        
        var displayName: String {
            switch self {
            case .userDefaults: return "User Defaults"
            case .routes: return "Routes"
            case .deeplinks: return "Deeplinks"
            case .analytics: return "Analytics"
            case .impersonate: return "Impersonate"
            }
        }
        
        var icon: String {
            switch self {
            case .userDefaults: return "flag.fill"
            case .routes: return "car.rear.road.lane"
            case .deeplinks: return "link.circle.fill"
            case .analytics: return "chart.line.uptrend.xyaxis"
            case .impersonate: return "person.crop.square.filled.and.at.rectangle.fill"
            }
        }
        
        var routeForDevSetting: Route {
            switch self {
            case .userDefaults: return .devSetting(.userDefaults)
            case .routes: return .devSetting(.routes)
            case .deeplinks: return .devSetting(.deeplinks)
            case .analytics: return .devSetting(.analytics)
            case .impersonate: return .devSetting(.impersonate)
            }
        }
        
    }

    case auth(AuthRoute)
    case onboarding(OnboardingRoute)
    case settings(SettingRoute)
    case devSetting(DevSettingRoute)
    
}

//
//  OnboardingPage.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/19/24.
//

import Foundation

enum OnboardingPage: String, CaseIterable, Identifiable {
    
    var id: String { self.rawValue }
    
    case businessSetup
    case locationControl
    case photos
    case beforeAndAfter
    case documentation
    case permission
    
    var title: String {
        switch self {
        case .businessSetup: return "Set Up Your Business"
        case .locationControl: return "Manage Your Locations"
        case .photos: return "Capture & Edit"
        case .beforeAndAfter: return "Before & After"
        case .documentation: return "Smart Documentation"
        case .permission: return "Permissions Needed"
        }
    }
    
    var message: String {
        switch self {
        case .businessSetup: return "Add your business info to unlock the full app experience."
        case .locationControl: return "Invite staff, manage roles, and keep locations organized."
        case .photos: return "Camera and editing toolbox built for aesthetics."
        case .beforeAndAfter: return "Show results. Build trust. Drive revenue."
        case .documentation: return "Save time with secure treatment notes and forms."
        case .permission: return ""
        }
    }
    
    var illustration: ImageSource {
        switch self {
        case .businessSetup: return .image(.illustrationTutorial1)
        case .locationControl: return .image(.illustrationTutorial2)
        case .photos: return .image(.illustrationTutorial3)
        case .beforeAndAfter: return .image(.illustrationTutorial4)
        case .documentation: return .image(.illustrationTutorial5)
        case .permission: fatalError("Unsupported case: \(self)")
        }
    }
    
}

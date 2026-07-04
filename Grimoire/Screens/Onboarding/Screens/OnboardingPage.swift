//
//  OnboardingPage.swift
//  Grimoire
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
        case .businessSetup: return "Add your business details to start managing clients, employees, and locations right away."
        case .locationControl: return "Invite staff, manage roles, and keep locations organized."
        case .photos: return "Camera and editing toolbox built for aesthetics."
        case .beforeAndAfter: return "Show results. Build trust. Drive revenue."
        case .documentation: return "Save time with secure treatment notes and forms."
        case .permission: return ""
        }
    }
    
    var illustration: ImageSource {
        switch self {
        case .businessSetup: return .systemImage("person.fill")
        case .locationControl: return .systemImage("person.fill")
        case .photos: return .systemImage("person.fill")
        case .beforeAndAfter: return .systemImage("person.fill")
        case .documentation: return .systemImage("person.fill")
        case .permission: fatalError("Unsupported case: \(self)")
        }
    }
    
}

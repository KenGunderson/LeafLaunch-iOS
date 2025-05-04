//
//  Constants.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/22/25.
//


import UIKit

struct Constants {
    
    // MARK: - DEVICE
    
    struct PList {
        
        static let url: URL = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        
    }
    
    struct Device {
        
        let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device_id"
        
    }
    
    // MARK: - ANALYTICS
    
    struct Analytics {
        
        static let AMPLITUDE_KEY = "ada7ff63079f5b1fb72b83af7216f0a1"
        
    }
    
    // MARK: - URLS
    
    struct URLs {
        
        static let defaultCustomEnvironmentAddress = "http://localhost:3000/api"
                
        static func urlForEnvironment(_ env: AppEnvironment) -> String {
            
            switch env {
            case .custom(let address): return "\(address)"
            case .localhost: return self.defaultCustomEnvironmentAddress
            case .development: return "https://api-dev-efmy4.ondigitalocean.app/api"
            case .production: return "https://api-dev-efmy4.ondigitalocean.app/api"
            }
            
        }
        
        static func analyticsUrlForEnvironment(_ env: AppEnvironment) -> String {
            
            switch env {
            case .custom(let address): return "\(address)"
            case .localhost: return "http://localhost:4000/api"
            case .development: return "http://localhost:4000/api"
            case .production: return "http://localhost:4000/api"
            }
            
        }
        
    }
    
    // MARK: - ANIMATIONS
    
    struct LottieFile {
        
        static let BIRTHDAY = "birthday"
        
    }
    
    // MARK: - LEGAL
    
    struct Legal {
        
        static let supportEmail: String = "test@support.com"
        
        // MARK: - PRIVACY POLICY
        
        static let privacyPolicy = ""
        
        // MARK: - TERMS OF SERVICE
        
        static let termsOfService = ""
        
    }
    
    struct WhatsNewItems {
        
        static let items: [WhatsNewItem] = [
            
            WhatsNewItem(
                version: SemanticVersion("1.0.0"),
                items: [
                    .init(
                        title: "Welcome to the latest version!",
                        message: "Thanks for downloading the latest version! We hope you enjoy it.",
                        icon: "heart.fill",
                        foregroundStyle: Style.shared.accent
                    ),
                    .init(
                        title: "New Features!",
                        message: "We found a way to make your life easier!",
                        icon: "lightbulb.fill",
                        foregroundStyle: Style.shared.accent
                    ),
                    .init(
                        title: "Everything else...",
                        message: "Consolidated all the features into one place!. Check it out!",
                        icon: "house.fill",
                        foregroundStyle: Style.shared.accent
                    )
                ]
            )
            
        ]
        
    }
    
}

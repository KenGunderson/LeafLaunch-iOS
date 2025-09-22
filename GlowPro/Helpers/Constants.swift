//
//  Constants.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/22/25.
//

import UIKit
import SwiftUI

struct Constants {
    
    // MARK: - DEVICE
    
    struct PList {
        
        static let url: URL = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        
    }
    
    @MainActor
    struct Device {
        
        static let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device_id"
        
    }
    
    // MARK: - ANALYTICS
    
    struct Analytics {
        
        static let AMPLITUDE_KEY = "9352310171a2e540fb3f609be7490127"
        
    }
    
    // MARK: - URLS
    
    struct URLs {
        
        static let defaultCustomEnvironmentAddress = "http://localhost:3000/api"
                
        static func urlForEnvironment(_ env: AppEnvironment) -> String {
            
            switch env {
            case .custom(let address): return "\(address)"
            case .localhost: return self.defaultCustomEnvironmentAddress
            case .development: return self.defaultCustomEnvironmentAddress // "https://glowpro-api-l9on3.ondigitalocean.app/api"
            case .production: return "https://glowpro-api-l9on3.ondigitalocean.app/api"
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
        
    }
    
    struct StaggerAnimation {
        
        static func config(interitemSpacing: CGFloat = 8) -> StaggeredConfig {
            
            return StaggeredConfig(
                delay: 0.05,
                maxDelay: 0.05,
                blurRadius: 0.5,
                offset: .init(width: 0, height: 100),
                scale: 1,
                scaleAnchor: .center,
                animation: .smooth.delay(0.3),
                interitemSpacing: interitemSpacing,
                disappearInSameDirection: true,
                noDisappearAnimation: false
            )
            
        }
        
    }
    
    // MARK: - LEGAL
    
    struct Legal {
        
        static let supportEmail: String = "support@glowpromd.app"
        
        // MARK: - PRIVACY POLICY
        
        static let privacyPolicy = ""
        
        // MARK: - TERMS OF SERVICE
        
        static let termsOfService = ""
        
    }
    
    struct Message {
        
        enum Context {
            
            case get
            case create
            case update
            case delete
            
            var verbDescription: String {
                switch self {
                case .get: return "getting"
                case .create: return "creating"
                case .update: return "updating"
                case .delete: return "deleting"
                }
            }
            
        }
        
        static func errorMessage(context: Context = .get, _ topic: String) -> String {
            return "Something went wrong while \(context.verbDescription) your \(topic). Please try again later."
        }
        
        static func deleteConfirmationTitle(_ topic: String) -> String {
            return "Delete \(topic)?"
        }
        
        static func deleteConfirmationMessage(_ topic: String) -> String {
            return "You are attemping to delete your \(topic). This action cannot be undone. Are you sure you wish to continue?"
        }
        
    }
    
    struct WhatsNewItems {
        
        static var items: [WhatsNewItem] {
            
            return [
                
                WhatsNewItem(
                    version: SemanticVersion("1.0.0"),
                    items: [
                        .init(
                            title: "Welcome to the latest version!",
                            message: "Thanks for downloading the latest version! We hope you enjoy it.",
                            icon: "heart.fill"
                        ),
                        .init(
                            title: "New Features!",
                            message: "We found a way to make your life easier!",
                            icon: "lightbulb.fill"
                        ),
                        .init(
                            title: "Everything else...",
                            message: "Consolidated all the features into one place!. Check it out!",
                            icon: "house.fill"
                        )
                    ]
                )
                
            ]
            
        }
        
    }
        
}

extension Constants {
    
    static func INVALID_EMAIL_ALERT() -> RuneAlert {
        
        return .init(.appAlert(.error(
            message: "Your email address is invalid. Please try again.",
            buttonTitle: "Okay",
            action: {
                
            })))
        
    }
    
}

extension Constants {
    
    static func HEALTH_CHECK_ENV_ALERT(action: @escaping () -> ()) -> EnviornmentAlertViewConfig {
        
        .init(
            title: "API Down 🙃",
            titleColor: Style.shared.textColor(.title),
            message: "We seem to be experiences technical difficulties. Please try again later.",
            messageColor: Style.shared.textColor(.body),
            image: Image(systemName: "stethoscope.circle.fill"),
            imageColor: Style.shared.background(.error),
            buttonTitle: "Try Again",
            buttonTitleColor: Style.shared.textColor(.button),
            buttonColor: Style.shared.background(.error),
            action: {
                action()
            }
        )
        
    }
    
    static func NO_NETWORK_ENV_ALERT(action: @escaping () -> ()) -> EnviornmentAlertViewConfig {
        
        .init(
            title: "No Network",
            titleColor: Style.shared.textColor(.title),
            message: "You seem to me be missing your internet connection.",
            messageColor: Style.shared.textColor(.body),
            image: Image(systemName: "wifi.slash"),
            imageColor: Style.shared.accent,
            buttonTitle: "Try Again",
            buttonTitleColor: Style.shared.textColor(.button),
            buttonColor: Style.shared.accent,
            action: {
                action()
            }
        )
        
    }
    
    static func FORCE_UPDATE_ENV_ALERT(action: @escaping () -> ()) -> EnviornmentAlertViewConfig {
        
        .init(
            title: "Old App Version",
            titleColor: Style.shared.textColor(.title),
            message: "Your app version is too old. Please go to the store and download the latest build.",
            messageColor: Style.shared.textColor(.body),
            image: Image(systemName: "building.2.crop.circle.fill"),
            imageColor: .color(.blue),
            buttonTitle: "Update Now",
            buttonTitleColor: Style.shared.textColor(.button),
            buttonColor: .color(.blue),
            action: {
                action()
            }
        )
        
    }
    
}

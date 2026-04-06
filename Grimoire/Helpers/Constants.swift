//
//  Constants.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 4/22/25.
//

import UIKit
import SwiftUI

struct Constants {
    
    // MARK: - FEATURES
    
    struct Feature {
        
        static let isWhatsNewEnabled: Bool = true
        static let isOnboardingEnabled: Bool = true
        
    }
    
    // MARK: - DEVICE
    
    struct PList {
        
        static let url: URL = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        
    }

    // MARK: - RUNTIME

    struct Runtime {
        
        static let apiRequestTimeout: TimeInterval = 30
        static let apiResourceTimeout: TimeInterval = 90
        static let apiRetryCount: Int = 2
        static let apiRetryBackoffBaseNanoseconds: UInt64 = 400_000_000
        
        static let fallbackEnvironment: AppEnvironment = .development
        
        @MainActor
        static let deviceHeight: CGFloat = UIScreen.currentHeight ?? 0

    }
    
    @MainActor
    struct Device {
        
        static let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device_id"
        
    }
    
    // MARK: - APP
    
    struct App {
        
        static let appName: String = "Grimoire"
        static let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unavailable"
        static let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unavailable"
        static let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "Unavailable"
        
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
            case .development: return "https://glowpro-api-l9on3.ondigitalocean.app/api"
            case .production: return "https://glowpro-api-l9on3.ondigitalocean.app/api"
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
        
        static let supportEmail: String = "support@glowpromd.com"
        
        // MARK: - PRIVACY POLICY
        
        static let privacyPolicy = ""
        
        // MARK: - TERMS OF SERVICE
        
        static let termsOfService = ""
        
    }
    
    // MARK: - CAMERA
    
    struct Camera {
        
        static let DEFAULT_OPACITY: Double = 0.85
        static let DEFAULT_SCALE: Double = 0.50
        
    }
    
    // MARK: - LOGGER
    
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
    
    // MARK: - WHAT'S NEW
    
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
    
    // MARK: - STATES
    
    enum USState: String, CaseIterable, Selectable {
        
        var id: String { return self.rawValue }
        
        case AL, AK, AZ, AR, CA, CO, CT, DE, FL, GA
        case HI, ID, IL, IN, IA, KS, KY, LA, ME, MD
        case MA, MI, MN, MS, MO, MT, NE, NV, NH, NJ
        case NM, NY, NC, ND, OH, OK, OR, PA, RI, SC
        case SD, TN, TX, UT, VT, VA, WA, WV, WI, WY
        
        var description: String {
            switch self {
            case .AL: return "Alabama"
            case .AK: return "Alaska"
            case .AZ: return "Arizona"
            case .AR: return "Arkansas"
            case .CA: return "California"
            case .CO: return "Colorado"
            case .CT: return "Connecticut"
            case .DE: return "Delaware"
            case .FL: return "Florida"
            case .GA: return "Georgia"
            case .HI: return "Hawaii"
            case .ID: return "Idaho"
            case .IL: return "Illinois"
            case .IN: return "Indiana"
            case .IA: return "Iowa"
            case .KS: return "Kansas"
            case .KY: return "Kentucky"
            case .LA: return "Louisiana"
            case .ME: return "Maine"
            case .MD: return "Maryland"
            case .MA: return "Massachusetts"
            case .MI: return "Michigan"
            case .MN: return "Minnesota"
            case .MS: return "Mississippi"
            case .MO: return "Missouri"
            case .MT: return "Montana"
            case .NE: return "Nebraska"
            case .NV: return "Nevada"
            case .NH: return "New Hampshire"
            case .NJ: return "New Jersey"
            case .NM: return "New Mexico"
            case .NY: return "New York"
            case .NC: return "North Carolina"
            case .ND: return "North Dakota"
            case .OH: return "Ohio"
            case .OK: return "Oklahoma"
            case .OR: return "Oregon"
            case .PA: return "Pennsylvania"
            case .RI: return "Rhode Island"
            case .SC: return "South Carolina"
            case .SD: return "South Dakota"
            case .TN: return "Tennessee"
            case .TX: return "Texas"
            case .UT: return "Utah"
            case .VT: return "Vermont"
            case .VA: return "Virginia"
            case .WA: return "Washington"
            case .WV: return "West Virginia"
            case .WI: return "Wisconsin"
            case .WY: return "Wyoming"
            }
        }
    }
    
}

extension Constants {
    
    // MARK: - ALERTS
    
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

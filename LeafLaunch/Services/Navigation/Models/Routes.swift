//
//  Routes.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import UIKit

protocol Navigation {
    //
}

enum Route: Navigation, Hashable, Sendable {

    enum CustomerRoute: Hashable, Sendable {

        case product(locationId: String, productId: String)
        case favoriteProducts(locationId: String)
        case pointsActivity(locationId: String)
        case events(locationId: String)
        case event(locationId: String, event: StoreEvent)
        case promotionProducts(locationId: String, promotionId: String, title: String, products: [PromotionLinkedProduct])

    }

    enum AuthRoute {

        case welcome
        case login
        case signup

    }

    enum SettingRoute: String, CaseIterable {

        case contactSupport
        case rateApp
        case privacyPolicy
        case termsOfService
        case logout

        var displayName: String {
            switch self {
            case .contactSupport: return "Contact Support"
            case .rateApp: return "Rate Our App"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .logout: return "Logout"
            }
        }

        var icon: ImageSource {
            switch self {
            case .contactSupport: return .systemImage("envelope.fill")
            case .rateApp: return .systemImage("star.fill")
            case .privacyPolicy: return .systemImage("lock.fill")
            case .termsOfService: return .systemImage("clipboard.fill")
            case .logout: return .systemImage("xmark.circle.fill")
            }
        }

        var tintColor: ColorSource {
            switch self {
            case .logout: .palette(.error)
            default: .foreground(.primary)
            }
        }

        var category: String {
            switch self {
            case .contactSupport, .rateApp: return "Help & Feedback"
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

        var displayName: String {
            switch self {
            case .userDefaults: return "User Defaults"
            case .routes: return "Routes"
            case .deeplinks: return "Deeplinks"
            case .analytics: return "Analytics"
            }
        }

        var icon: String {
            switch self {
            case .userDefaults: return "flag.fill"
            case .routes: return "car.rear.road.lane"
            case .deeplinks: return "link.circle.fill"
            case .analytics: return "chart.line.uptrend.xyaxis"
            }
        }

        var routeForDevSetting: Route {
            switch self {
            case .userDefaults: return .devSetting(.userDefaults)
            case .routes: return .devSetting(.routes)
            case .deeplinks: return .devSetting(.deeplinks)
            case .analytics: return .devSetting(.analytics)
            }
        }

    }

    case auth(AuthRoute)
    case settings(SettingRoute)
    case devSetting(DevSettingRoute)
    case customer(CustomerRoute)

}

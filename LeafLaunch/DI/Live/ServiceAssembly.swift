//
//  ServiceAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import FactoryKit
import UIKit

extension Container {

    // ENV

    var environmentService: Factory<EnvironmentServiceProtocol> {
        self { @MainActor in
            EnvironmentService()
        }
        .singleton
    }

    // ALERT

    var alertService: Factory<AlertServiceProtocol> {
        self { @MainActor in
            AlertService()
        }
        .singleton
    }

    // ANALYTICS

    var analyticsService: Factory<AnalyticsServiceProtocol> {
        self { @MainActor in
            AnalyticsService(
                environmentService: self.environmentService()
            )
        }
        .singleton
    }

    // APP DELEGATE

    var appDelegateService: Factory<AppDelegateServiceProtocol> {
        self { @MainActor in
            AppDelegateService()
        }
        .singleton
    }

    // DEEP LINK

    var deeplinkService: Factory<DeeplinkServiceProtocol> {
        self { @MainActor in
            DeeplinkService(
                lifecycleService: self.viewLifecycleService()
            )
        }
        .singleton
    }

    // FIREBASE

    var firebaseService: Factory<FirebaseServiceProtocol> {
        self { @MainActor in
            FirebaseService()
        }
        .singleton
    }

    // USER DEFAULTS

    var userDefaultsService: Factory<UserDefaultsServiceProtocol> {
        self { @MainActor in
            UserDefaultsService(style: Style.shared)
        }
        .singleton
    }

    // CONNECTIVITY

    var connectivityService: Factory<ConnectivityServiceProtocol> {
        self { @MainActor in
            ConnectivityService()
        }
        .singleton
    }

    // PUSH NOTIFICATION

    var pushNotificationService: Factory<PushNotificationServiceProtocol> {
        self { @MainActor in
            PushNotificationService(
                viewLifecycleService: self.viewLifecycleService()
            )
        }
        .singleton
    }

    // LAUNCH

    var launchScreenService: Factory<LaunchScreenServiceProtocol> {
        self { @MainActor in
            LaunchScreenService()
        }
        .singleton
    }

    // VIEW LIFECYCLE

    var viewLifecycleService: Factory<ViewLifecycleServiceProtocol> {
        self { @MainActor in
            ViewLifecycleService()
        }
        .singleton
    }

    // API

    var apiService: Factory<APIServiceProtocol> {
        self { @MainActor in
            APIService(
                analyticsService: self.analyticsService(),
                environmentService: self.environmentService(),
                appDelegateService: self.appDelegateService(),
                firebaseService: self.firebaseService()
            )
        }
        .singleton
    }

    // CUSTOMER STORE SESSION

    var tabBarNavigationService: Factory<TabBarNavigationService> {
        self { @MainActor in TabBarNavigationService() }
            .singleton
    }

    var storeSessionService: Factory<StoreSessionServiceProtocol> {
        self { @MainActor in
            StoreSessionService(
                apiService: self.apiService(),
                authService: self.authService(),
                userDefaultsService: self.userDefaultsService(),
                tabBarNavigationService: self.tabBarNavigationService()
            )
        }
        .singleton
    }

    // AUTH

    var authService: Factory<AuthServiceProtocol> {
        self { @MainActor in
            AuthService(
                firebaseService: self.firebaseService(),
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
        .singleton
    }

    // ROOT STARTUP

    var rootStartupService: Factory<RootStartupServiceProtocol> {
        self { @MainActor in
            RootStartupService(
                launchService: self.launchScreenService(),
                environmentService: self.environmentService(),
                apiService: self.apiService(),
                authService: self.authService(),
                firebaseService: self.firebaseService(),
                appDelegateService: self.appDelegateService(),
                connectivityService: self.connectivityService(),
                viewLifecycleService: self.viewLifecycleService(),
                storeSessionService: self.storeSessionService()
            )
        }
        .singleton
    }

}

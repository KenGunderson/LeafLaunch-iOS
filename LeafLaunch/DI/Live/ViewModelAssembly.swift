//
//  ViewModelAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import FactoryKit

extension Container {

    // RootViewModel

    @MainActor
    var rootViewModel: Factory<RootViewModel> {
        self { @MainActor in
            RootViewModel(
                analyticsService: self.analyticsService(),
                alertService: self.alertService(),
                authService: self.authService(),
                pushNotificationService: self.pushNotificationService(),
                userDefaultsService: self.userDefaultsService(),
                deeplinkService: self.deeplinkService(),
                startupService: self.rootStartupService(),
                mainViewModel: self.mainViewModel()
            )
        }
    }

    // MainViewModel

    @MainActor
    var mainViewModel: Factory<MainViewModel> {
        self { @MainActor in
            MainViewModel(
                alertService: self.alertService(),
                appDelegateService: self.appDelegateService(),
                analyticsService: self.analyticsService(),
                pushNotificationsService: self.pushNotificationService(),
                environmentService: self.environmentService(),
                storeSessionService: self.storeSessionService(),
                tabBarNavigationService: self.tabBarNavigationService(),
                makeStoreContainerViewModel: { self.storeContainerViewModel() }
            )
        }
    }

    // Home

    @MainActor
    var homeViewModel: Factory<HomeViewModel> {
        self { @MainActor in HomeViewModel(analyticsService: self.analyticsService()) }
    }

    // Auth - Welcome

    @MainActor
    var welcomeViewModel: Factory<WelcomeViewModel> {
        self { @MainActor in
            WelcomeViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // Auth - Login

    @MainActor
    var loginViewModel: Factory<LoginViewModel> {
        self { @MainActor in
            LoginViewModel(
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // Auth - SignUp

    @MainActor
    var signUpViewModel: Factory<SignUpViewModel> {
        self { @MainActor in
            SignUpViewModel(
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // Settings

    @MainActor
    var settingsViewModel: Factory<SettingsViewModel> {
        self { @MainActor in
            SettingsViewModel(
                authService: self.authService(),
                apiService: self.apiService(),
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                environmentService: self.environmentService(),
                userDefaultsService: self.userDefaultsService(),
                viewLifecycleService: self.viewLifecycleService()
            )
        }
    }

    // Settings - Legal

    @MainActor
    var legalDetailsViewModel: Factory<LegalDetailsViewModel> {
        self { @MainActor in
            LegalDetailsViewModel(
                apiService: self.apiService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // DevSettings

    @MainActor
    var devSettingsViewModel: Factory<DevSettingsViewModel> {
        self { @MainActor in
            DevSettingsViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                firebaseService: self.firebaseService(),
                appDelegateService: self.appDelegateService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // DevSettings - Routes

    @MainActor
    var devRouteListViewModel: Factory<DevRouteListViewModel> {
        self { @MainActor in
            DevRouteListViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // DevSettings - Deeplinks

    @MainActor
    var devDeeplinkListViewModel: Factory<DevDeeplinkListViewModel> {
        self { @MainActor in
            DevDeeplinkListViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

    // DevSettings - UserDefaults

    @MainActor
    var devUserDefaultsViewModel: Factory<DevUserDefaultsViewModel> {
        self { @MainActor in
            DevUserDefaultsViewModel(
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }

    // DevSettings - Analytics

    @MainActor
    var devAnalyticsListViewModel: Factory<DevAnalyticsListViewModel> {
        self { @MainActor in
            DevAnalyticsListViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

}

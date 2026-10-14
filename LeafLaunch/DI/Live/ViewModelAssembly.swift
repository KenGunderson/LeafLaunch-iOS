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
                startupService: self.rootStartupService()
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
                firebaseService: self.firebaseService(),
                authService: self.authService(),
                pushNotificationsService: self.pushNotificationService(),
                environmentService: self.environmentService()
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
    
    // Tab 1 ViewModel
    
    @MainActor
    var tab1ViewModel: Factory<Tab1ViewModel> {
        self { @MainActor in
            Tab1ViewModel(
                alertService: self.alertService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // Tab 2 ViewModel
    
    @MainActor
    var tab2ViewModel: Factory<Tab2ViewModel> {
        self { @MainActor in
            Tab2ViewModel(
                alertService: self.alertService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // Tab 3 ViewModel
    
    @MainActor
    var tab3ViewModel: Factory<Tab3ViewModel> {
        self { @MainActor in
            Tab3ViewModel(
                authService: self.authService(),
                analyticsService: self.analyticsService()
            )
        }
    }
    
    // Tab 4 ViewModel
    
    @MainActor
    var tab4ViewModel: Factory<Tab4ViewModel> {
        self { @MainActor in
            Tab4ViewModel(
                authService: self.authService(),
                analyticsService: self.analyticsService()
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
    
    // Settings - PROFILE
    
    @MainActor
    var profileViewModel: Factory<ProfileViewModel> {
        self { @MainActor in
            ProfileViewModel(
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                alertService: self.alertService(),
                userDefaultsService: self.userDefaultsService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // Settings - Legal
    
    @MainActor
    var legalViewModel: Factory<LegalViewModel> {
        self { @MainActor in
            LegalViewModel(
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
    var devRoutesViewModel: Factory<DevRoutesViewModel> {
        self { @MainActor in
            DevRoutesViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // DevSettings - Deeplinks
    
    @MainActor
    var devDeeplinksViewModel: Factory<DevDeeplinksViewModel> {
        self { @MainActor in
            DevDeeplinksViewModel(
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
    var devAnalyticsViewModel: Factory<DevAnalyticsViewModel> {
        self { @MainActor in
            DevAnalyticsViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }

}

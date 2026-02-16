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
    
    var rootViewModel: Factory<RootViewModel> {
        self {
            RootViewModel(
                analyticsService: self.analyticsService(),
                alertService: self.alertService(),
                authService: self.authService(),
                impersonateService: self.impersonateService(),
                pushNotificationService: self.pushNotificationService(),
                userDefaultsService: self.userDefaultsService(),
                deeplinkService: self.deeplinkService(),
                startupService: self.rootStartupService()
            )
        }
    }
    
    // MainViewModel
    
    var mainViewModel: Factory<MainViewModel> {
        self {
            MainViewModel(
                alertService: self.alertService(),
                appDelegateService: self.appDelegateService(),
                analyticsService: self.analyticsService(),
                firebaseService: self.firebaseService(),
                authService: self.authService(),
                userDefaultsService: self.userDefaultsService(),
                viewLifecycleService: self.viewLifecycleService(),
                pushNotificationsService: self.pushNotificationService(),
                permissionsService: self.permissionsService()
            )
        }
    }
    
    // Auth - Welcome
    
    var welcomeViewModel: Factory<WelcomeViewModel> {
        self {
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
    
    var loginViewModel: Factory<LoginViewModel> {
        self {
            LoginViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // Auth - SignUp
    
    var signUpViewModel: Factory<SignUpViewModel> {
        self {
            SignUpViewModel(
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // Onboarding ViewModel
    
    var onboardingViewModel: Factory<OnboardingViewModel> {
        self {
            OnboardingViewModel(
                analyticsService: self.analyticsService(),
                permissionService: self.permissionsService(),
                alertService: self.alertService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // Onboarding Permission ViewModel
    
    var onboardingPermissionsViewModel: Factory<OnboardingPermissionsViewModel> {
        self {
            OnboardingPermissionsViewModel(
                analyticsService: self.analyticsService(),
                permissionService: self.permissionsService(),
                alertService: self.alertService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // Tab 1 ViewModel
    
    var tab1ViewModel: Factory<Tab1ViewModel> {
        self {
            Tab1ViewModel(
                alertService: self.alertService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // Tab 2 ViewModel
    
    var tab2ViewModel: Factory<Tab2ViewModel> {
        self {
            Tab2ViewModel(
                alertService: self.alertService(),
                authService: self.authService(),
                analyticsService: self.analyticsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // Tab 3 ViewModel
    
    var tab3ViewModel: Factory<Tab3ViewModel> {
        self {
            Tab3ViewModel(
                authService: self.authService(),
                analyticsService: self.analyticsService()
            )
        }
    }
    
    // Tab 4 ViewModel
    
    var tab4ViewModel: Factory<Tab4ViewModel> {
        self {
            Tab4ViewModel(
                authService: self.authService(),
                analyticsService: self.analyticsService()
            )
        }
    }
    
    // Settings
    
    var settingsViewModel: Factory<SettingsViewModel> {
        self {
            SettingsViewModel(
                authService: self.authService(),
                apiService: self.apiService(),
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                environmentService: self.environmentService(),
                userDefaultsService: self.userDefaultsService(),
                viewLifecycleService: self.viewLifecycleService(),
                impersonateService: self.impersonateService()
            )
        }
    }
    
    // Settings - PROFILE
    
    var profileViewModel: Factory<ProfileViewModel> {
        self {
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
    
    // Settings - ABOUT US
    
    var aboutUsViewModel: Factory<AboutUsViewModel> {
        self {
            AboutUsViewModel(
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // Settings - FEATURE REQUEST
    
    var featureRequestViewModel: Factory<FeatureRequestViewModel> {
        self {
            FeatureRequestViewModel(
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // Settings - FAQ
    
    var faqViewModel: Factory<FAQViewModel> {
        self {
            FAQViewModel(
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // Settings - Legal
    
    var legalViewModel: Factory<LegalViewModel> {
        self {
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
    
    var devSettingsViewModel: Factory<DevSettingsViewModel> {
        self {
            DevSettingsViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                firebaseService: self.firebaseService(),
                alertService: self.alertService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // DevSettings - Routes
    
    var devRoutesViewModel: Factory<DevRoutesViewModel> {
        self {
            DevRoutesViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // DevSettings - Deeplinks
    
    var devDeeplinksViewModel: Factory<DevDeeplinksViewModel> {
        self {
            DevDeeplinksViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // DevSettings - UserDefaults
    
    var devUserDefaultsViewModel: Factory<DevUserDefaultsViewModel> {
        self {
            DevUserDefaultsViewModel(
                alertService: self.alertService(),
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService(),
                permissionService: self.permissionsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
    }
    
    // DevSettings - Analytics
    
    var devAnalyticsViewModel: Factory<DevAnalyticsViewModel> {
        self {
            DevAnalyticsViewModel(
                analyticsService: self.analyticsService(),
                authService: self.authService(),
                viewLifecycleService: self.viewLifecycleService(),
                environmentService: self.environmentService()
            )
        }
    }
    
    // DevSettings - Impersonate
    
    var devImpersonateViewModel: Factory<DevImpersonateViewModel> {
        self {
            DevImpersonateViewModel(
                analyticsService: self.analyticsService(),
                impersonateService: self.impersonateService(),
                viewLifecycleService: self.viewLifecycleService(),
                alertService: self.alertService(),
                environmentService: self.environmentService()
            )
        }
    }
    
}

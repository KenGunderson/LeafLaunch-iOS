//
//  MockViewModelAssembly.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/23/24.
//

import Foundation
import FactoryKit

class MockViewModelAssembly {
    
    func assemble(container: Container) {

        // RootViewModel
        
        container.rootViewModel.register { @MainActor in
            RootViewModel(
                analyticsService: container.analyticsService(),
                alertService: container.alertService(),
                authService: container.authService(),
                impersonateService: container.impersonateService(),
                pushNotificationService: container.pushNotificationService(),
                userDefaultsService: container.userDefaultsService(),
                deeplinkService: container.deeplinkService(),
                startupService: container.rootStartupService()
            )
        }

        // MainViewModel
        
        container.mainViewModel.register { @MainActor in
            MainViewModel(
                alertService: container.alertService(),
                appDelegateService: container.appDelegateService(),
                analyticsService: container.analyticsService(),
                firebaseService: container.firebaseService(),
                authService: container.authService(),
                userDefaultsService: container.userDefaultsService(),
                viewLifecycleService: container.viewLifecycleService(),
                pushNotificationsService: container.pushNotificationService(),
                permissionsService: container.permissionsService(),
                environmentService: container.environmentService()
            )
        }
        
        // Auth - Welcome
        
        container.welcomeViewModel.register { @MainActor in
            WelcomeViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                alertService: container.alertService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Auth - Login
        
        container.loginViewModel.register { @MainActor in
            LoginViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Auth - SignUp
        
        container.signUpViewModel.register { @MainActor in
            SignUpViewModel(
                alertService: container.alertService(),
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Onboarding ViewModel
        
        container.onboardingViewModel.register { @MainActor in
            OnboardingViewModel(
                analyticsService: container.analyticsService(),
                permissionService: container.permissionsService(),
                alertService: container.alertService(),
                userDefaultsService: container.userDefaultsService()
            )
        }
        
        // Onboarding Permission ViewModel
        
        container.onboardingPermissionsViewModel.register { @MainActor in
            OnboardingPermissionsViewModel(
                analyticsService: container.analyticsService(),
                permissionService: container.permissionsService(),
                alertService: container.alertService(),
                userDefaultsService: container.userDefaultsService()
            )
        }
        
        // Settings
        
        container.settingsViewModel.register { @MainActor in
            SettingsViewModel(
                authService: container.authService(),
                apiService: container.apiService(),
                alertService: container.alertService(),
                analyticsService: container.analyticsService(),
                environmentService: container.environmentService(),
                userDefaultsService: container.userDefaultsService(),
                viewLifecycleService: container.viewLifecycleService(),
                impersonateService: container.impersonateService()
            )
        }
        
        // Settings - PROFILE
        
        container.profileViewModel.register { @MainActor in
            ProfileViewModel(
                apiService: container.apiService(),
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                alertService: container.alertService(),
                userDefaultsService: container.userDefaultsService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Settings - ABOUT US
        
        container.aboutUsViewModel.register { @MainActor in
            AboutUsViewModel(
                apiService: container.apiService(),
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                alertService: container.alertService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Settings - FEATURE REQUEST
        
        container.featureRequestViewModel.register { @MainActor in
            FeatureRequestViewModel(
                apiService: container.apiService(),
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                alertService: container.alertService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Settings - FAQ
        
        container.faqViewModel.register { @MainActor in
            FAQViewModel(
                apiService: container.apiService(),
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                alertService: container.alertService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // Settings - Legal
        
        container.legalViewModel.register { @MainActor in
            LegalViewModel(
                apiService: container.apiService(),
                authService: container.authService(),
                analyticsService: container.analyticsService(),
                alertService: container.alertService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // What's New
        
        container.whatsNewViewModel.register { @MainActor in
            WhatsNewViewModel(
                analyticsService: container.analyticsService(),
                userDefaultsService: container.userDefaultsService()
            )
        }
        
        // DevSettings
        
        container.devSettingsViewModel.register { @MainActor in
            DevSettingsViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                firebaseService: container.firebaseService(),
                appDelegateService: container.appDelegateService(),
                impersonateService: container.impersonateService(),
                alertService: container.alertService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // DevSettings - Routes
        
        container.devRoutesViewModel.register { @MainActor in
            DevRoutesViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // DevSettings - Deeplinks
        
        container.devDeeplinksViewModel.register { @MainActor in
            DevDeeplinksViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // DevSettings - UserDefaults
        
        container.devUserDefaultsViewModel.register { @MainActor in
            DevUserDefaultsViewModel(
                alertService: container.alertService(),
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService(),
                permissionService: container.permissionsService(),
                userDefaultsService: container.userDefaultsService()
            )
        }
        
        // DevSettings - Analytics
        
        container.devAnalyticsViewModel.register { @MainActor in
            DevAnalyticsViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                viewLifecycleService: container.viewLifecycleService(),
                environmentService: container.environmentService()
            )
        }
        
        // DevSettings - Impersonate
        
        container.devImpersonateViewModel.register { @MainActor in
            DevImpersonateViewModel(
                analyticsService: container.analyticsService(),
                impersonateService: container.impersonateService(),
                viewLifecycleService: container.viewLifecycleService(),
                alertService: container.alertService(),
                environmentService: container.environmentService()
            )
        }

    }
    
}

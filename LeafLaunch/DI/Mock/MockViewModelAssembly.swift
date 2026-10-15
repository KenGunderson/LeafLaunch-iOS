//
//  MockViewModelAssembly.swift
//  LeafLaunch
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
                pushNotificationService: container.pushNotificationService(),
                userDefaultsService: container.userDefaultsService(),
                deeplinkService: container.deeplinkService(),
                startupService: container.rootStartupService(),
                mainViewModel: container.mainViewModel()
            )
        }

        // MainViewModel

        container.mainViewModel.register { @MainActor in
            MainViewModel(
                alertService: container.alertService(),
                appDelegateService: container.appDelegateService(),
                analyticsService: container.analyticsService(),
                pushNotificationsService: container.pushNotificationService(),
                environmentService: container.environmentService(),
                storeSessionService: container.storeSessionService(),
                tabBarNavigationService: container.tabBarNavigationService(),
                makeStoreDetailsViewModel: { container.storeDetailsViewModel() }
            )
        }

        // Home

        container.homeViewModel.register { @MainActor in
            HomeViewModel(analyticsService: container.analyticsService())
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
                alertService: container.alertService(),
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

        // Settings

        container.settingsViewModel.register { @MainActor in
            SettingsViewModel(
                authService: container.authService(),
                apiService: container.apiService(),
                alertService: container.alertService(),
                analyticsService: container.analyticsService(),
                environmentService: container.environmentService(),
                userDefaultsService: container.userDefaultsService(),
                viewLifecycleService: container.viewLifecycleService()
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

        // DevSettings

        container.devSettingsViewModel.register { @MainActor in
            DevSettingsViewModel(
                analyticsService: container.analyticsService(),
                authService: container.authService(),
                firebaseService: container.firebaseService(),
                appDelegateService: container.appDelegateService(),
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

    }

}

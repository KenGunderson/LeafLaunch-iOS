//
//  MockViewModelAssembly.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/23/24.
//

import Foundation
import Swinject

class MockViewModelAssembly: Assembly {
    
    func assemble(container: Container) {

        // RootViewModel
        
        container.register(RootViewModel.self) { r in
            RootViewModel(
                launchService: r.resolve(LaunchScreenServiceProtocol.self)!,
                analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                environmentService: r.resolve(EnvironmentServiceProtocol.self)!,
                alertService: r.resolve(AlertServiceProtocol.self)!,
                apiService: r.resolve(APIServiceProtocol.self)!,
                authService: r.resolve(AuthServiceProtocol.self)!,
                impersonateService: r.resolve(ImpersonateServiceProtocol.self)!,
                firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                appDelegateService: r.resolve(AppDelegateServiceProtocol.self)!,
                connectivityService: r.resolve(ConnectivityServiceProtocol.self)!,
                viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                pushNotificationService: r.resolve(PushNotificationServiceProtocol.self)!,
                deeplinkService: r.resolve(DeeplinkServiceProtocol.self)!
            )
        }.inObjectScope(.transient)

        // MainViewModel
        
        container.register(MainViewModel.self) { r in
            MainViewModel(
                appDelegateService: r.resolve(AppDelegateServiceProtocol.self)!,
                analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                authService: r.resolve(AuthServiceProtocol.self)!,
                userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                pushNotificationsService: r.resolve(PushNotificationServiceProtocol.self)!,
                permissionsService: r.resolve(PermissionsServiceProtocol.self)!
            )
        }.inObjectScope(.transient)
        
        // Auth - Welcome
        
        container
            .register(WelcomeViewModel.self) { r in
                WelcomeViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Auth - Login
        
        container
            .register(LoginViewModel.self) { r in
                LoginViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Auth - SignUp
        
        container
            .register(SignUpViewModel.self) { r in
                SignUpViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // What's New ViewModel
        
        container
            .register(WhatsNewViewModel.self) { r in
                WhatsNewViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // Tab 1 ViewModel
        
        container
            .register(Tab1ViewModel.self) { r in
                Tab1ViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // Tab 2 ViewModel
        
        container
            .register(Tab2ViewModel.self) { r in
                Tab2ViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // Tab 3 ViewModel
        
        container
            .register(Tab3ViewModel.self) { r in
                Tab3ViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // Tab 4 ViewModel
        
        container
            .register(Tab4ViewModel.self) { r in
                Tab4ViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // ClientList
        
        container
            .register(ClientListViewModel.self) { r in
                ClientListViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // DevSettings
        
        container
            .register(DevSettingsViewModel.self) { r in
                DevSettingsViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // DevSettings - Routes
        
        container
            .register(DevRoutesViewModel.self) { r in
                DevRoutesViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // DevSettings - Deeplinks
        
        container
            .register(DevDeeplinksViewModel.self) { r in
                DevDeeplinksViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // DevSettings - UserDefaults
        
        container
            .register(DevUserDefaultsViewModel.self) { r in
                DevUserDefaultsViewModel(
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!,
                    permissionService: r.resolve(PermissionsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // DevSettings - Analytics
        
        container
            .register(DevAnalyticsViewModel.self) { r in
                DevAnalyticsViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // DevSettings - Impersonate
        
        container
            .register(DevImpersonateViewModel.self) { r in
                DevImpersonateViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    impersonateService: r.resolve(ImpersonateServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)

    }
    
}

//
//  ViewModelAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import Swinject

final class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // RootViewModel
        
        container
            .register(RootViewModel.self) { r in
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
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    deeplinkService: r.resolve(DeeplinkServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // MainViewModel
        
        container
            .register(MainViewModel.self) { r in
                MainViewModel(
                    alertService: r.resolve(AlertServiceProtocol.self)!,
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
                    alertService: r.resolve(AlertServiceProtocol.self)!,
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
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Onboarding ViewModel
        
        container
            .register(OnboardingViewModel.self) { r in
                OnboardingViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    permissionService: r.resolve(PermissionsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Onboarding Permission ViewModel
        
        container
            .register(OnboardingPermissionsViewModel.self) { r in
                OnboardingPermissionsViewModel(
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    permissionService: r.resolve(PermissionsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Tab 1 ViewModel
        
        container
            .register(Tab1ViewModel.self) { r in
                Tab1ViewModel(
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }
        
        // Tab 2 ViewModel
        
        container
            .register(Tab2ViewModel.self) { r in
                Tab2ViewModel(
                    alertService: r.resolve(AlertServiceProtocol.self)!,
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
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!
                )
            }
        
        // Tab 4 ViewModel
        
        container
            .register(Tab4ViewModel.self) { r in
                Tab4ViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!
                )
            }
        
        // Settings
        
        container
            .register(SettingsViewModel.self) { r in
                SettingsViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    impersonateService: r.resolve(ImpersonateServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Settings - PROFILE
        
        container
            .register(ProfileViewModel.self) { r in
                ProfileViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Settings - ABOUT US
        
        container
            .register(AboutUsViewModel.self) { r in
                AboutUsViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Settings - FEATURE REQUEST
        
        container
            .register(FeatureRequestViewModel.self) { r in
                FeatureRequestViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Settings - FAQ
        
        container
            .register(FAQViewModel.self) { r in
                FAQViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Settings - Legal
        
        container
            .register(LegalViewModel.self) { r in
                LegalViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
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

//
//  ViewModelAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import Swinject

class ViewModelAssembly: Assembly {
    
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
                    deeplinkService: r.resolve(DeeplinkServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // MainViewModel
        
        container
            .register(MainViewModel.self) { r in
                MainViewModel(
                    appDelegateService: r.resolve(AppDelegateServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
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
        
        // Home
        
        container
            .register(HomeViewModel.self) { r in
                HomeViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                    launchService: r.resolve(LaunchScreenServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Home
        
        container
            .register(BusinessHomeViewModel.self) { r in
                BusinessHomeViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Details
        
        container
            .register(BusinessCreateEditViewModel.self) { r in
                BusinessCreateEditViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Locations
        
        container
            .register(BusinessLocationListViewModel.self) { r in
                BusinessLocationListViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Location Create
        
        container
            .register(BusinessLocationCreateEditViewModel.self) { r in
                BusinessLocationCreateEditViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Location Home
        
        container
            .register(BusinessLocationHomeViewModel.self) { r in
                BusinessLocationHomeViewModel(
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Employees
        
        container
            .register(BusinessEmployeeListViewModel.self) { r in
                BusinessEmployeeListViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Employee Invite
        
        container
            .register(BusinessEmployeeInviteViewModel.self) { r in
                BusinessEmployeeInviteViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Employee Invite List
        
        container
            .register(BusinessEmployeeInviteListViewModel.self) { r in
                BusinessEmployeeInviteListViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Employee Update
        
        container
            .register(BusinessEmployeeUpdateViewModel.self) { r in
                BusinessEmployeeUpdateViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Employee Details
        
        container
            .register(BusinessEmployeeDetailsViewModel.self) { r in
                BusinessEmployeeDetailsViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Client Create
        
        container
            .register(ClientCreateEditViewModel.self) { r in
                ClientCreateEditViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Business Activities List
        
        container
            .register(BusinessActivityListViewModel.self) { r in
                BusinessActivityListViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Client List
        
        container
            .register(ClientListViewModel.self) { r in
                ClientListViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Client Details
        
        container
            .register(ClientHomeViewModel.self) { r in
                ClientHomeViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Media Camera
        
        container
            .register(CameraViewModel.self) { r in
                CameraViewModel(
                    cameraService: r.resolve(CameraServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                )
            }.inObjectScope(.transient)
        
        // Media Gallery
        
        container
            .register(MediaGalleryViewModel.self) { r in
                MediaGalleryViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Media Preview
        
        container
            .register(MediaPreviewViewModel.self) { r in
                MediaPreviewViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Media Tags
        
        container
            .register(MediaTagViewModel.self) { r in
                MediaTagViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Media Review
        
        container
            .register(MediaReviewViewModel.self) { r in
                MediaReviewViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    mediaTransferService: r.resolve(MediaTransferServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Note List
        
        container
            .register(NoteListViewModel.self) { r in
                NoteListViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                )
            }.inObjectScope(.transient)
        
        // Note Create Edit
        
        container
            .register(NoteCreateEditViewModel.self) { r in
                NoteCreateEditViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    mediaTransferService: r.resolve(MediaTransferServiceProtocol.self)!,
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!,
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Security Pin
        
        container
            .register(SecurityPinInputViewModel.self) { r in
                SecurityPinInputViewModel(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    activeDestinationService: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    alertService: r.resolve(AlertServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
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
                    impersonateService: r.resolve(ImpersonateServiceProtocol.self)!
                )
            }.inObjectScope(.transient)
        
        // Settings - SECURITY
        
        container
            .register(SecurityViewModel.self) { r in
                SecurityViewModel(
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

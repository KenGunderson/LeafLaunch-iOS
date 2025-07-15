//
//  ServiceAssembly.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Swinject
import UIKit

final
class ServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // ENV
        
        container
            .register(EnvironmentServiceProtocol.self) { r in
                EnvironmentService()
            }.inObjectScope(.container)
        
        // ALERT
        
        container
            .register(AlertServiceProtocol.self) { r in
                AlertService()
            }.inObjectScope(.container)
        
        container
            .register(AnalyticsServiceProtocol.self) { r in
                AnalyticsService(
                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!,
                    permissionService: r.resolve(PermissionsServiceProtocol.self)!,
                    impersonateService: nil
                )
            }
            .inObjectScope(.container)
            .initCompleted { r, service in
                let analyticsService = service as! AnalyticsService
                analyticsService.set(impersonateService: r.resolve(ImpersonateServiceProtocol.self)!)
            }
        
        // APP DELEGATE
        
        container
            .register(AppDelegateServiceProtocol.self) { r in
                AppDelegateService()
            }.inObjectScope(.container)
        
        // DEEP LINK
        
        container
            .register(DeeplinkServiceProtocol.self) { r in
                DeeplinkService(
                    lifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.container)
        
        // FIREBASE
        
        container
            .register(FirebaseServiceProtocol.self) { r in
                FirebaseService()
            }.inObjectScope(.container)
        
        // USER DEFAULTS
        
        container
            .register(UserDefaultsServiceProtocol.self) { r in
                UserDefaultsService()
            }.inObjectScope(.container)
        
        // CONNECTIVITY
        
        container
            .register(ConnectivityServiceProtocol.self) { r in
                ConnectivityService()
            }.inObjectScope(.container)
        
        // PUSH NOTIFICATION
        
        container
            .register(PushNotificationServiceProtocol.self) { r in
                PushNotificationService(
                    viewLifecycleService: r.resolve(ViewLifecycleServiceProtocol.self)!
                )
            }.inObjectScope(.container)
        
        // LAUNCH
        
        container
            .register(LaunchScreenServiceProtocol.self) { r in
                LaunchScreenService()
            }.inObjectScope(.container)
        
        // CAMERA PERMISSION
        
        container
            .register(CameraPermissionServiceProtocol.self) { r in
                CameraPermissionService()
            }.inObjectScope(.container)
        
        // MEDIA PERMISSION
        
        container
            .register(MediaPermissionServiceProtocol.self) { r in
                MediaPermissionService()
            }.inObjectScope(.container)
        
        // PUSH NOTIFICATION PERMISSION
        
        container
            .register(PushNotificationPermissionServiceProtocol.self) { r in
                PushNotificationPermissionService()
            }.inObjectScope(.container)
        
        // APP TRACKING PERMISSION
        
        container
            .register(AppTrackingPermissionServiceProtocol.self) { r in
                AppTrackingPermissionService()
            }.inObjectScope(.container)
        
        // VIEW LIFECYCLE
        
        container
            .register(ViewLifecycleServiceProtocol.self) { r in
                ViewLifecycleService()
            }.inObjectScope(.container)
        
        // PERMISSIONS SERVICE
        
        container
            .register(PermissionsServiceProtocol.self) { r in
                PermissionsService(
                    cameraPermissionService: r.resolve(CameraPermissionServiceProtocol.self)!,
                    mediaPermissionService: r.resolve(MediaPermissionServiceProtocol.self)!,
                    pushNotificationPermissionService: r.resolve(PushNotificationPermissionServiceProtocol.self)!,
                    appTrackingPermissionService: r.resolve(AppTrackingPermissionServiceProtocol.self)!
                )
            }.inObjectScope(.container)
        
        // API
        
        container
            .register(APIServiceProtocol.self) { r in
                MockAPIService() // TODO: - REPLACE WITH LIVE
//                APIService(
//                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
//                    environmentService: r.resolve(EnvironmentServiceProtocol.self)!,
//                    appDelegateService: r.resolve(AppDelegateServiceProtocol.self)!,
//                    firebaseService: r.resolve(FirebaseServiceProtocol.self)!
//                )
            }.inObjectScope(.container)
        
        // AUTH
        
        container
            .register(AuthServiceProtocol.self) { r in
                AuthService(
                    firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    activeDestination: r.resolve(ActiveDestinationServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.container)
        
        // IMPERSONATE
        
        container
            .register(ImpersonateServiceProtocol.self) { r in
                ImpersonateService(
                    firebaseService: r.resolve(FirebaseServiceProtocol.self)!,
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    authService: r.resolve(AuthServiceProtocol.self)!,
                    userDefaultsService: r.resolve(UserDefaultsServiceProtocol.self)!
                )
            }.inObjectScope(.container)
        
        // ACTIVE DESTINATION
        
        container
            .register(ActiveDestinationServiceProtocol.self) { r in
                ActiveDestinationService(
                    apiService: r.resolve(APIServiceProtocol.self)!,
                    analyticsService: r.resolve(AnalyticsServiceProtocol.self)!
                )
            }.inObjectScope(.container)
        
    }
    
}

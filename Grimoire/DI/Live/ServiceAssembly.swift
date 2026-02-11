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
        self {
            EnvironmentService()
        }
        .singleton
    }
    
    // ALERT
    
    var alertService: Factory<AlertServiceProtocol> {
        self {
            AlertService()
        }
        .singleton
    }
    
    // ANALYTICS
    
    var analyticsService: Factory<AnalyticsServiceProtocol> {
        self {
            AnalyticsService(
                environmentService: self.environmentService(),
                permissionService: self.permissionsService()
            )
        }
        .singleton
    }
    
    // APP DELEGATE
    
    var appDelegateService: Factory<AppDelegateServiceProtocol> {
        self {
            AppDelegateService()
        }
        .singleton
    }
    
    // DEEP LINK
    
    var deeplinkService: Factory<DeeplinkServiceProtocol> {
        self {
            DeeplinkService(
                lifecycleService: self.viewLifecycleService()
            )
        }
        .singleton
    }
    
    // FIREBASE
    
    var firebaseService: Factory<FirebaseServiceProtocol> {
        self {
            FirebaseService()
        }
        .singleton
    }
    
    // USER DEFAULTS
    
    var userDefaultsService: Factory<UserDefaultsServiceProtocol> {
        self {
            UserDefaultsService()
        }
        .singleton
    }
    
    // CONNECTIVITY
    
    var connectivityService: Factory<ConnectivityServiceProtocol> {
        self {
            ConnectivityService()
        }
        .singleton
    }
    
    // PUSH NOTIFICATION
    
    var pushNotificationService: Factory<PushNotificationServiceProtocol> {
        self {
            PushNotificationService(
                viewLifecycleService: self.viewLifecycleService()
            )
        }
        .singleton
    }
    
    // LAUNCH
    
    var launchScreenService: Factory<LaunchScreenServiceProtocol> {
        self {
            LaunchScreenService()
        }
        .singleton
    }
    
    // CAMERA PERMISSION
    
    var cameraPermissionService: Factory<CameraPermissionServiceProtocol> {
        self {
            CameraPermissionService()
        }
        .singleton
    }
    
    // MEDIA PERMISSION
    
    var mediaPermissionService: Factory<MediaPermissionServiceProtocol> {
        self {
            MediaPermissionService()
        }
        .singleton
    }
    
    // PUSH NOTIFICATION PERMISSION
    
    var pushNotificationPermissionService: Factory<PushNotificationPermissionServiceProtocol> {
        self {
            PushNotificationPermissionService()
        }
        .singleton
    }
    
    // APP TRACKING PERMISSION
    
    var appTrackingPermissionService: Factory<AppTrackingPermissionServiceProtocol> {
        self {
            AppTrackingPermissionService()
        }
        .singleton
    }
    
    // VIEW LIFECYCLE
    
    var viewLifecycleService: Factory<ViewLifecycleServiceProtocol> {
        self {
            ViewLifecycleService()
        }
        .singleton
    }
    
    // PERMISSIONS SERVICE
    
    var permissionsService: Factory<PermissionsServiceProtocol> {
        self {
            PermissionsService(
                cameraPermissionService: self.cameraPermissionService(),
                mediaPermissionService: self.mediaPermissionService(),
                pushNotificationPermissionService: self.pushNotificationPermissionService(),
                appTrackingPermissionService: self.appTrackingPermissionService()
            )
        }
        .singleton
    }
    
    // API
    
    var apiService: Factory<APIServiceProtocol> {
        self {
//            MockAPIService() // TODO: - REPLACE WITH LIVE
            APIService(
                analyticsService: self.analyticsService(),
                environmentService: self.environmentService(),
                appDelegateService: self.appDelegateService(),
                firebaseService: self.firebaseService()
            )
        }
        .singleton
    }
    
    // AUTH
    
    var authService: Factory<AuthServiceProtocol> {
        self {
            AuthService(
                firebaseService: self.firebaseService(),
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
        .singleton
    }
    
    // IMPERSONATE
    
    var impersonateService: Factory<ImpersonateServiceProtocol> {
        self {
            ImpersonateService(
                firebaseService: self.firebaseService(),
                apiService: self.apiService(),
                authService: self.authService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
        .singleton
    }
    
}

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
        self { @MainActor in
            EnvironmentService()
        }
        .singleton
    }
    
    // ALERT
    
    var alertService: Factory<AlertServiceProtocol> {
        self { @MainActor in
            AlertService()
        }
        .singleton
    }
    
    // ANALYTICS
    
    var analyticsService: Factory<AnalyticsServiceProtocol> {
        self { @MainActor in
            MockAnalyticsService() // TODO: - REPLACE WITH LIVE
//            AnalyticsService(
//                environmentService: self.environmentService(),
//                permissionService: self.permissionsService()
//            )
        }
        .singleton
    }
    
    // APP DELEGATE
    
    var appDelegateService: Factory<AppDelegateServiceProtocol> {
        self { @MainActor in
            AppDelegateService()
        }
        .singleton
    }
    
    // DEEP LINK
    
    var deeplinkService: Factory<DeeplinkServiceProtocol> {
        self { @MainActor in
            DeeplinkService(
                lifecycleService: self.viewLifecycleService()
            )
        }
        .singleton
    }
    
    // FIREBASE
    
    var firebaseService: Factory<FirebaseServiceProtocol> {
        self { @MainActor in
            FirebaseService()
        }
        .singleton
    }
    
    // USER DEFAULTS
    
    var userDefaultsService: Factory<UserDefaultsServiceProtocol> {
        self { @MainActor in
            UserDefaultsService()
        }
        .singleton
    }
    
    // CONNECTIVITY
    
    var connectivityService: Factory<ConnectivityServiceProtocol> {
        self { @MainActor in
            ConnectivityService()
        }
        .singleton
    }
    
    // PUSH NOTIFICATION
    
    var pushNotificationService: Factory<PushNotificationServiceProtocol> {
        self { @MainActor in
            PushNotificationService(
                viewLifecycleService: self.viewLifecycleService(),
                localNotificationService: self.localNotificationService()
            )
        }
        .singleton
    }
    
    // LOCAL NOTIFICATION
    
    var localNotificationService: Factory<LocalNotificationServiceProtocol> {
        self { @MainActor in
            LocalNotificationService()
        }
        .singleton
    }
    
    // APP STORE SUBSCRIPTION
    
    var appStoreSubscriptionService: Factory<AppStoreSubscriptionServiceProtocol> {
        self { @MainActor in
            AppStoreSubscriptionService(
                productIdentifiers: []
            )
        }
        .singleton
    }
    
    // LAUNCH
    
    var launchScreenService: Factory<LaunchScreenServiceProtocol> {
        self { @MainActor in
            LaunchScreenService()
        }
        .singleton
    }
    
    // CAMERA PERMISSION
    
    var cameraPermissionService: Factory<CameraPermissionServiceProtocol> {
        self { @MainActor in
            CameraPermissionService()
        }
        .singleton
    }
    
    // MEDIA PERMISSION
    
    var mediaPermissionService: Factory<MediaPermissionServiceProtocol> {
        self { @MainActor in
            MediaPermissionService()
        }
        .singleton
    }
    
    // PUSH NOTIFICATION PERMISSION
    
    var pushNotificationPermissionService: Factory<PushNotificationPermissionServiceProtocol> {
        self { @MainActor in
            PushNotificationPermissionService(
                localNotificationService: self.localNotificationService()
            )
        }
        .singleton
    }
    
    // APP TRACKING PERMISSION
    
    var appTrackingPermissionService: Factory<AppTrackingPermissionServiceProtocol> {
        self { @MainActor in
            AppTrackingPermissionService()
        }
        .singleton
    }

    // MICROPHONE PERMISSION

    var microphonePermissionService: Factory<MicrophonePermissionServiceProtocol> {
        self { @MainActor in
            MicrophonePermissionService()
        }
        .singleton
    }

    // SPEECH RECOGNITION PERMISSION

    var speechRecognitionPermissionService: Factory<SpeechRecognitionPermissionServiceProtocol> {
        self { @MainActor in
            SpeechRecognitionPermissionService()
        }
        .singleton
    }
    
    // VIEW LIFECYCLE
    
    var viewLifecycleService: Factory<ViewLifecycleServiceProtocol> {
        self { @MainActor in
            ViewLifecycleService()
        }
        .singleton
    }
    
    // PERMISSIONS SERVICE
    
    var permissionsService: Factory<PermissionsServiceProtocol> {
        self { @MainActor in
            PermissionsService(
                cameraPermissionService: self.cameraPermissionService(),
                mediaPermissionService: self.mediaPermissionService(),
                pushNotificationPermissionService: self.pushNotificationPermissionService(),
                appTrackingPermissionService: self.appTrackingPermissionService(),
                microphonePermissionService: self.microphonePermissionService(),
                speechRecognitionPermissionService: self.speechRecognitionPermissionService()
            )
        }
        .singleton
    }

    // VOICE TRANSCRIPTION

    var voiceTranscriptionService: Factory<VoiceTranscriptionServiceProtocol> {
        self { @MainActor in
            VoiceTranscriptionService(
                microphonePermissionService: self.microphonePermissionService(),
                speechRecognitionPermissionService: self.speechRecognitionPermissionService()
            )
        }
        .singleton
    }
    
    // API
    
    var apiService: Factory<APIServiceProtocol> {
        self { @MainActor in
            MockAPIService() // TODO: - REPLACE WITH LIVE
//            APIService(
//                analyticsService: self.analyticsService(),
//                environmentProvider: self.environmentService(),
//                deviceTokenProvider: self.appDelegateService(),
//                authTokenProvider: self.firebaseService()
//            )
        }
        .singleton
    }
    
    // AUTH
    
    var authService: Factory<AuthServiceProtocol> {
        self { @MainActor in
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
        self { @MainActor in
            ImpersonateService(
                firebaseService: self.firebaseService(),
                apiService: self.apiService(),
                authService: self.authService(),
                userDefaultsService: self.userDefaultsService()
            )
        }
        .singleton
    }
    
    // STATSIG

    var statsigService: Factory<StatsigServiceProtocol> {
        self { @MainActor in
            StatsigService()
        }
        .singleton
    }

    // ROOT STARTUP
    
    var rootStartupService: Factory<RootStartupServiceProtocol> {
        self { @MainActor in
            RootStartupService(
                launchService: self.launchScreenService(),
                environmentService: self.environmentService(),
                apiService: self.apiService(),
                authService: self.authService(),
                impersonateService: self.impersonateService(),
                firebaseService: self.firebaseService(),
                appDelegateService: self.appDelegateService(),
                connectivityService: self.connectivityService(),
                viewLifecycleService: self.viewLifecycleService(),
                statsigService: self.statsigService()
            )
        }
        .singleton
    }
    
}

//
//  MockServiceAssembly.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/23/24.
//

import Foundation
import Combine
import AuthenticationServices
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import AppTrackingTransparency
import FactoryKit
import StripePaymentSheet
import AVFoundation

// MARK: - AnalyticsServiceProtocol

final class MockAnalyticsService: AnalyticsServiceProtocol {
    
    internal let loggerName: String = "ANALYTICS_SERVICE"
    internal let loggerEmoji: String = "📀"
        
    var currentUserId = CurrentValueSubject<String?, Never>(nil)
    
    @Published var sessionEvents: [EventData] = []
    var sessionEventsPublisher: AnyPublisher<[EventData], Never> {
        return self.$sessionEvents.eraseToAnyPublisher()
    }
    
    // MARK: Public
    
    func identifyUser(_ userId: String?) {
        
        self.log(message: "identify: \(userId ?? "nil")")
        self.currentUserId.send(userId)
        
        // Logging
        self.log(message: "USER_ID: \(userId ?? "NIL")")
        
        let loggingEvent = EventData(
            name: "identify",
            properties: ["user_id": (userId != nil) ? userId! : "nil"]
        )
        
        sessionEvents.append(loggingEvent)
    }
    
    func setUserProperty(_ key: String, value: String) {
        
        self.log(message: "user_property: [\(key): \(value)]")
        self.log(message: "User property: \(key)\n METADATA:\nkey: \(key),\nvalue: \(value)")
    
        let loggingEvent = EventData(
            name: "user_property",
            properties: [key: value]
        )
        
        sessionEvents.append(loggingEvent)
    }
    
    func track(_ app: AppEvent) {
        track(event: app)
    }
    
    func track(screen: ScreenEvent) {
        track(event: screen)
    }
    
    func track(error: ErrorEvent) {
        track(event: error)
    }
    
    func clearSessionEvents() {
        self.sessionEvents = []
    }
    
    func logout() {
        
        self.log(message: "logout")
        self.currentUserId.send(nil)
        identifyUser(nil)
        
    }
    
    // MARK: Private
    
    private func track(event: AnalyticsEvent) {
        
        let type = event.eventType
        let data = event.eventData
                
        let message = (data.properties != nil) ?
            "\(data.name): \(data.properties!)" :
            data.name
        
        var debugLogMessage = "Analytics event"
        
        switch type {
        case .app:
            debugLogMessage = "App: \(data.name)"
            
        case .screen:
            if let screenName = data.properties?["screen"] as? String {
                debugLogMessage = "Screen: \(screenName)"
            }
            else {
                debugLogMessage = "Screen event"
            }
            
        case .error:
            if let errorName = data.properties?["name"] as? String {
                debugLogMessage = "Error: \(errorName)"
            }
            else {
                debugLogMessage = "Error event"
            }
        }

        self.log(message: "\(type.displayName.uppercased()):\n\(message)\n\(debugLogMessage)")
        
        sessionEvents.append(data)
    }
    
}

// MARK: - MockAlertService

final class MockAlertService: AlertServiceProtocol, ObservableObject, @unchecked Sendable {
    
    @Published var alerts: [RuneAlert] = []
    
    var alertsPublisher: AnyPublisher<[RuneAlert], Never> {
        return self.$alerts.eraseToAnyPublisher()
    }
    
    @Published var requestedToDeleteAlert = false
    var requestedToDeleteAlertPublisher: AnyPublisher<Bool, Never> {
        return self.$requestedToDeleteAlert.eraseToAnyPublisher()
    }
    
    func showAlert(_ alert: RuneAlert) {
        self.alerts.append(alert)
    }
    
    func dismissAlert(_ alert: RuneAlert) {
        alerts.removeAll { alert.id == $0.id }
    }
    
    func dismiss(_ animated: Bool = true) {
        alerts.removeLast()
    }
    
    func dismissAll() {
        alerts.removeAll()
    }
    
    func dismissImmediately() {
        alerts.removeLast()
    }
    
    func setRequestToDeleteAlert(_ shouldRequest: Bool) {
        self.requestedToDeleteAlert = shouldRequest
    }
    
    func dismissLoadingIndicator() {
        
        if let loadingAlert = self.alerts.first(where: { $0.alert == .simpleLoadingIndicator }) {
            alerts.removeAll { loadingAlert.id == $0.id }
        }
        
    }
    
}

// MARK: - APIServiceProtocol

final class MockAPIService: APIServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "API_SERVICE"
    internal let loggerEmoji: String = "🌐"
    
    var accessToken: String? = nil
    var deviceToken: String? = nil
    var environment: AppEnvironment? = nil
    let networkSession: URLSession = .shared
    let requestTimeout: TimeInterval = Constants.Runtime.apiRequestTimeout
    let resourceTimeout: TimeInterval = Constants.Runtime.apiResourceTimeout
    let maxRetryCount: Int = 0
    let retryBackoffNanoseconds: UInt64 = Constants.Runtime.apiRetryBackoffBaseNanoseconds
    
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(.localhost)
    }
    
    private var currentUser: GPUser
    
    init() {
        
        let user = MockModels.MockUser.user1
        self.currentUser = user
        
    }
    
    // Health
    
    func getHealth() async throws {}
    
    // Users
    
    func getUser(id: String) async throws -> GPUser {
        
        let user = MockModels.MockUser.user1
        return user
        
    }
    
    func getUserProfile() async throws -> GPUser {
        
        let user = MockModels.MockUser.user1
        return user
        
    }
    
    func getFirebaseTokenForUser(email: String) async throws -> String { return "MOCK_TOKEN" }
    func updateUser(user: GPUser) async throws {}
    func createUser(user: GPUser) async throws -> GPUser { user }
    func deleteUser(user: GPUser) async throws {}
    
    // Device
    
    func registerDevice(token: String, userId: String) async throws {}

}

// MARK: - AppDelegateServiceProtocol

final class MockAppDelegateService: AppDelegateServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "APP_DELEGATE_SERVICE"
    internal let loggerEmoji: String = "📱"
    
    var deviceToken: String? = nil
    var deviceTokenPublisher = CurrentValueSubject<String?, Never>(nil).eraseToAnyPublisher()
    var onNotificationPublisher = PassthroughSubject<UNNotification?, Never>()
    var onTappedNotificationPublisher = PassthroughSubject<UNNotification?, Never>()
    var appWillTerminatePublisher: PassthroughSubject<Void, Never> = .init()
    
    func setup(appDelegate: AppDelegate) {}
    func clearNotification() {}
    
}

// MARK: - AppTrackingPermissionServiceProtocol

final class MockAppTrackingPermissionService: AppTrackingPermissionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "APP_TRACKING_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    var permissionGranted: Bool? = nil
    var permissionGrantedPublisher = CurrentValueSubject<Bool?, Never>(nil).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var attStatus: ATTStatus? = nil
    var attStatusPublisher = CurrentValueSubject<ATTStatus?, Never>(nil).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - AuthServiceProtocol

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "AUTH_SERVICE"
    internal let loggerEmoji: String = "🪪"
    
    private let apiService: APIServiceProtocol = MockAPIService()
    
    var currentUser: GPUser? = MockModels.MockUser.user1
    var currentUserPublisher = CurrentValueSubject<GPUser?, Never>(MockModels.MockUser.user1).eraseToAnyPublisher()
    var onInitialLoadCompleted = CurrentValueSubject<Bool, Never>(false)
    var onError = CurrentValueSubject<Error?, Never>(nil)
    
    init() {
        self.currentUser = MockModels.MockUser.user1
    }
    
    func signup(firstName: String, lastName: String, email: String, password: String) async throws {
        self.currentUser = MockModels.MockUser.user1
    }
    
    func login(email: String, password: String) async throws {
        
        let currentUser = MockModels.MockUser.user1
        self.currentUser = currentUser
        
    }
    
    func handleAppleSignupOrLogin(currentNonce: String?, authorization: ASAuthorization, isLogin: Bool) async throws {}
    func fetchUserInfoWithToken() async throws {}
    func reloadUser() async throws {}
    func deleteUser() async throws {}
    func updateEmail(_ email: String) async throws {}
    func resetPassword(email: String) async throws {}
    func logout() async throws {}
    
}

// MARK: IMPERSONATE

final class MockImpersonateService: ImpersonateServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "IMPERSONATE_SERVICE"
    internal let loggerEmoji: String = "🥷🏻"
    
    internal var apiService: APIServiceProtocol = MockAPIService()
    internal var authService: AuthServiceProtocol = MockAuthService()
    internal var firebaseService: FirebaseServiceProtocol = MockFirebaseService()
    
    var originalUser: GPUser? = nil
    var originalUserPublisher = CurrentValueSubject<GPUser?, Never>(nil).eraseToAnyPublisher()
    
    var impersonatedUser: GPUser? = nil
    var impersonatedUserPublisher = CurrentValueSubject<GPUser?, Never>(nil).eraseToAnyPublisher()
    
    var isImpersonating: Bool {
        return false
    }
    
    func impersonateUser(email: String) async throws {}
    func revert() async throws {}
    func logout() {}
    
}

// MARK: - CameraPermissionServiceProtocol

final class MockCameraPermissionService: CameraPermissionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "CAMERA_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - ConnectivityServiceProtocol

final class MockConnectivityService: ConnectivityServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "CONNECTIVITY_SERVICE"
    internal let loggerEmoji: String = "📡"
    
    var onHasNetworkConnection = CurrentValueSubject<Bool, Never>(true)
    func setNetworkConnection(connection: Bool) {
        
    }
    
}

// MARK: - DeeplinkServiceProtocol

final class MockDeeplinkService: DeeplinkServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "DEEPLINK_SERVICE"
    internal let loggerEmoji: String = "🔗"
    
    func handle(url: URL) {}
    func setup(mainViewModel: MainViewModel?, tabBarNavigationService: TabBarNavigationService) {}
    
}

// MARK: - EnvironmentServiceProtocol

final class MockEnvironmentService: EnvironmentServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "ENVIRONMENT_SERVICE"
    internal let loggerEmoji: String = "♻️"
    
    var environment: AppEnvironment? = .development
    var environmentPublisher = CurrentValueSubject<AppEnvironment?, Never>(nil).eraseToAnyPublisher()
    
    func setEnvironment(_ environment: AppEnvironment) {}
    
}

// MARK: - FirebaseServiceProtocol

final class MockFirebaseService: FirebaseServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "FIREBASE_SERVICE"
    internal let loggerEmoji: String = "🔥"
    
    var user: FirebaseAuth.User? = nil
    var userPublisher = CurrentValueSubject<FirebaseAuth.User?, Never>(nil).eraseToAnyPublisher()
    var currentAccessToken: String? = nil
    var currentAccessTokenPublisher = CurrentValueSubject<String?, Never>(nil).eraseToAnyPublisher()
    
    var isSignUpContext: Bool = false
    var isLoginContext: Bool = false
    
    func setup() -> Self { self }
    
    func signup(email: String, password: String) async throws {}
    func login(email: String, password: String) async throws {}
    func login(customUserToken: String) async throws {}
    func login(token: String, nonce: String) async throws {}
    func handleAppleSignupOrLogin(currentNonce: String?, authorization: ASAuthorization, completion: @escaping (String?, String?, String, String, Error?) -> ()) {}
    func logout() throws {}
    func getAccessTokenForCurrentUser() async throws {}
    func resetPassword(email: String) async throws {}
    func updateEmail(newEmail: String) async throws {}
    func uploadImage(imageData: Data, bucket: Query.Bucket) async throws -> URL { URL(string: "https://example.com")! }
    
}

// MARK: - LaunchScreenServiceProtocol

final class MockLaunchScreenService: LaunchScreenServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "LAUNCH_SERVICE"
    internal let loggerEmoji: String = "🚀"
    
    var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)
    func setState(_ state: LaunchScreenService.State) {}
    
}

// MARK: - MediaPermissionServiceProtocol

final class MockMediaPermissionService: MediaPermissionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "MEDIA_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - PermissionsServiceProtocol

final class MockPermissionsService: PermissionsServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    var shouldShowPermissionView: Bool = false
    var shouldShowPermissionViewPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    var cameraPermissionService: CameraPermissionServiceProtocol = MockCameraPermissionService()
    var mediaPermissionService: MediaPermissionServiceProtocol = MockMediaPermissionService()
    var pushNotificationPermissionService: PushNotificationPermissionServiceProtocol = MockPushNotificationPermissionService()
    var appTrackingPermissionService: AppTrackingPermissionServiceProtocol = MockAppTrackingPermissionService()
    
    func validatePermissions() {}
    func requestPermission(_ permission: Permission) {}
    
}

// MARK: - PushNotificationPermissionServiceProtocol

final class MockPushNotificationPermissionService: PushNotificationPermissionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "PUSH_NOTIFICATION_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - PushNotificationServiceProtocol

final class MockPushNotificationService: PushNotificationServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "PUSH_NOTIFICATIONS_SERVICE"
    internal let loggerEmoji: String = "🔔"
    
    func parsePushNotification(_ pushNotification: UNNotification?, isTapped: Bool) {}
    func parseRemoteNotification(_ pushNotification: UNNotification, isTapped: Bool) {}
    func parseLocalNotification(_ pushNotification: UNNotification, isTapped: Bool) {}
    func setup(tabBarNavigationService: TabBarNavigationService) {}
    
}

// MARK: - LocalNotificationServiceProtocol

final class MockLocalNotificationService: LocalNotificationServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "LOCAL_NOTIFICATION_SERVICE"
    internal let loggerEmoji: String = "⏰"
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    var shouldPromptForPermissions: Bool = true
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
    
    func refreshAuthorizationStatus() {}
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
    func schedule(_ request: LocalNotificationScheduleRequest) async throws {}
    
    func decodeScheduledLocalNotification(from notification: UNNotification) -> LocalNotificationPayload? {
        return nil
    }
    
    func remakeScheduledLocalNotificationIfNeeded(from notification: UNNotification) async {}
    
    func getPlannedNotifications() async -> [LocalNotificationSnapshotItem] {
        return []
    }
    
    func getIncomingNotifications() async -> [LocalNotificationSnapshotItem] {
        return []
    }
    
    func clearPlannedNotifications() {}
    func clearIncomingNotifications() {}
    func clearAllNotifications() {}
    
}

// MARK: - UserDefaultsServiceProtocol

final class MockUserDefaultsService: UserDefaultsServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    var theme: AvailableTheme = .lightCyan
    var didCompleteOnboarding: Bool = false
    var didCompletePermission: Bool = false
    var didViewChecklistCompletionSheet: Bool = false
    var lastViewedWhatsNewVersion: String?
    var didRateMyAppAlertShow: Bool = false
    var impersonatingUserData: Data?
    var securityPinsDictionaryData: Data?
    var shouldHideScreenshots: Bool = false
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didCompletePermissionPublisher = PassthroughSubject<Bool, Never>()
    var didViewChecklistCompletionSheetPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var impersonatingUserDataPublisher = PassthroughSubject<Data?, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    var shouldHideScreenshotsPublisher = PassthroughSubject<Bool, Never>()
    
    func set(theme: AvailableTheme) {}
    func set(didCompleteOnboarding: Bool) {}
    func set(didCompletePermission: Bool) {}
    func set(didViewChecklistCompletionSheet: Bool) {}
    func set(lastViewedWhatsNewVersion: String?) {}
    func set(didRateMyAppAlertShow: Bool) {}
    func set(impersonatedUser: ImpersonatingUser?) {}
    func set(securityPin: String?, businessId: String) {}
    func set(shouldHideScreenshots: Bool) {}
    func resetDevFlags() {}
    
    func getSecurityPinForBusinessId(_ businessId: String) -> String? { return nil }
    
    func logout() async {}
    
}

// MARK: - ViewLifecycleServiceProtocol

final class MockViewLifecycleService: ViewLifecycleServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "VIEW_LIFECYCLE_SERVICE"
    internal let loggerEmoji: String = "🔁"
    
    var onShouldReloadView = CurrentValueSubject<Int, Never>(0)
    var onDidEnterBackground = CurrentValueSubject<String?, Never>(nil)
    var onDidBecomeActive = CurrentValueSubject<String?, Never>(nil)
    var onWillEnterForeground = CurrentValueSubject<String?, Never>(nil)
    
    func reload(for key: ViewLifecycleKey) {}
    func reload(for keys: [ViewLifecycleKey]) {}
    func reloadAll() {}
    func publisher(for key: ViewLifecycleKey) -> AnyPublisher<Void, Never> { return PassthroughSubject().eraseToAnyPublisher() }
    
}

// MARK: - Mock Service Assembly

final class MockServiceAssembly {
    
    func assemble(container: Container) {
        
        container.environmentService.register { @MainActor in MockEnvironmentService() }
        container.alertService.register { @MainActor in MockAlertService() }
        container.analyticsService.register { @MainActor in MockAnalyticsService() }
        container.appDelegateService.register { @MainActor in MockAppDelegateService() }
        container.deeplinkService.register { @MainActor in MockDeeplinkService() }
        container.firebaseService.register { @MainActor in MockFirebaseService() }
        container.userDefaultsService.register { @MainActor in MockUserDefaultsService() }
        container.connectivityService.register { @MainActor in MockConnectivityService() }
        container.pushNotificationService.register { @MainActor in MockPushNotificationService() }
        container.localNotificationService.register { @MainActor in MockLocalNotificationService() }
        container.launchScreenService.register { @MainActor in MockLaunchScreenService() }
        container.cameraPermissionService.register { @MainActor in MockCameraPermissionService() }
        container.mediaPermissionService.register { @MainActor in MockMediaPermissionService() }
        container.pushNotificationPermissionService.register { @MainActor in MockPushNotificationPermissionService() }
        container.appTrackingPermissionService.register { @MainActor in MockAppTrackingPermissionService() }
        container.viewLifecycleService.register { @MainActor in MockViewLifecycleService() }
        container.permissionsService.register { @MainActor in MockPermissionsService() }
        container.apiService.register { @MainActor in MockAPIService() }
        container.authService.register { @MainActor in MockAuthService() }
        container.impersonateService.register { @MainActor in MockImpersonateService() }
        container.rootStartupService.register { @MainActor in
            RootStartupService(
                launchService: container.launchScreenService(),
                environmentService: container.environmentService(),
                apiService: container.apiService(),
                authService: container.authService(),
                impersonateService: container.impersonateService(),
                firebaseService: container.firebaseService(),
                appDelegateService: container.appDelegateService(),
                connectivityService: container.connectivityService(),
                viewLifecycleService: container.viewLifecycleService()
            )
        }
        
    }
    
}

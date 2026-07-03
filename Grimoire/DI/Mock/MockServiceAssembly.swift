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
    let retryPolicy: APIRetryPolicy = .noRetry
    
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(.localhost)
    }

    func freshAccessToken() async throws(APIError) -> String? {
        return self.accessToken
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
    var currentAccessTokenExpirationDate: Date? = nil
    
    var isSignUpContext: Bool = false
    var isLoginContext: Bool = false
    
    func beginSignUpContext() {
        self.isSignUpContext = true
        self.isLoginContext = false
    }

    func beginLoginContext() {
        self.isSignUpContext = false
        self.isLoginContext = true
    }

    func clearAuthContext() {
        self.isSignUpContext = false
        self.isLoginContext = false
    }

    func setup() -> Self { self }
    
    func signup(email: String, password: String) async throws {}
    func login(email: String, password: String) async throws {}
    func login(token: String, nonce: String) async throws {}
    func handleAppleSignupOrLogin(currentNonce: String?, authorization: ASAuthorization, completion: @escaping (String?, String?, String, String, Error?) -> ()) {}
    func logout() throws {}
    func getAccessTokenForCurrentUser() async throws {}
    func freshAuthToken() async throws -> String? { return self.currentAccessToken }
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

// MARK: - MicrophonePermissionServiceProtocol

final class MockMicrophonePermissionService: MicrophonePermissionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "MICROPHONE_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🎙️"
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - SpeechRecognitionPermissionServiceProtocol

final class MockSpeechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "SPEECH_RECOGNITION_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🗣️"
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - VoiceTranscriptionServiceProtocol

final class MockVoiceTranscriptionService: VoiceTranscriptionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "VOICE_TRANSCRIPTION_SERVICE"
    internal let loggerEmoji: String = "🎤"
    
    var isRecording: Bool = false
    var isRecordingPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    var isTranscribing: Bool = false
    var isTranscribingPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    var partialTranscript: String = ""
    var partialTranscriptPublisher = CurrentValueSubject<String, Never>("").eraseToAnyPublisher()
    
    var finalTranscript: String = ""
    var finalTranscriptPublisher = CurrentValueSubject<String, Never>("").eraseToAnyPublisher()
    
    var lastRecordingURL: URL? = nil
    var lastRecordingURLPublisher = CurrentValueSubject<URL?, Never>(nil).eraseToAnyPublisher()
    
    var error: VoiceTranscriptionError? = nil
    var errorPublisher = CurrentValueSubject<VoiceTranscriptionError?, Never>(nil).eraseToAnyPublisher()
    
    var tempRecordings: [VoiceRecordingFile] = []
    var tempRecordingsPublisher = CurrentValueSubject<[VoiceRecordingFile], Never>([]).eraseToAnyPublisher()
    
    func startRecording() throws {}
    func stopRecording() throws {}
    func clearCurrentSession() {}
    
    func listTempRecordings() -> [VoiceRecordingFile] {
        return self.tempRecordings
    }
    
    func deleteTempFile(at url: URL) throws {}
    func deleteAllTempFiles() throws {}
    
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
    var microphonePermissionService: MicrophonePermissionServiceProtocol = MockMicrophonePermissionService()
    var speechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol = MockSpeechRecognitionPermissionService()
    
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
    
    func removeScheduledNotification(identifiers: [String]) {}
    
    func clearPlannedNotifications() {}
    func clearIncomingNotifications() {}
    func clearAllNotifications() {}
    
}

// MARK: - AppStoreSubscriptionServiceProtocol

final class MockAppStoreSubscriptionService: AppStoreSubscriptionServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "APP_STORE_SUBSCRIPTION_SERVICE"
    internal let loggerEmoji: String = "🛍️"
    
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .none
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        return self.$subscriptionStatus.eraseToAnyPublisher()
    }
    
    @Published private(set) var products: [SubscriptionProduct] = []
    var productsPublisher: AnyPublisher<[SubscriptionProduct], Never> {
        return self.$products.eraseToAnyPublisher()
    }
    
    func configure() async throws {
        self.products = self.mockProducts()
        self.subscriptionStatus = .none
    }
    
    func fetchProductOfferings() async throws -> [SubscriptionProduct] {
        
        if self.products.isEmpty {
            try await self.configure()
        }
        
        return self.products
        
    }
    
    func subscribe(to product: SubscriptionProduct) async throws -> SubscriptionStatus {
        
        let expiryDate: Date
        
        if product.id == "mock.subscription.monthly" {
            
            expiryDate = Calendar.current.date(
                byAdding: .month,
                value: 1,
                to: Date()
            ) ?? Date()
            
        } else {
            
            expiryDate = Calendar.current.date(
                byAdding: .year,
                value: 1,
                to: Date()
            ) ?? Date()
            
        }
        
        self.subscriptionStatus = .active(
            productId: product.id,
            expiryDate: expiryDate
        )
        
        return self.subscriptionStatus
        
    }
    
    func checkSubscriptionStatus() async throws -> SubscriptionStatus {
        return self.subscriptionStatus
    }
    
    func restoreSubscriptions() async throws -> SubscriptionStatus {
        
        if let monthlyProduct = self.mockProducts().first {
            
            self.subscriptionStatus = .active(
                productId: monthlyProduct.id,
                expiryDate: Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: Date()
                )
            )
            
        }
        
        return self.subscriptionStatus
        
    }
    
    func currentSubscriptionProduct() -> SubscriptionProduct? {
        
        guard case .active(let productId, _) = self.subscriptionStatus else {
            return nil
        }
        
        return self.mockProducts().first(where: { $0.id == productId })
        
    }
    
    private func mockProducts() -> [SubscriptionProduct] {
        
        return [
            
            SubscriptionProduct(
                id: "mock.subscription.monthly",
                title: "Monthly Membership",
                description: "Enjoy premium features every month.",
                price: 3.00,
                displayPrice: "$3.00"
            ),
            SubscriptionProduct(
                id: "mock.subscription.yearly",
                title: "Yearly Membership",
                description: "Enjoy premium features for the whole year.",
                price: 24.00,
                displayPrice: "$24.00"
            )
            
        ]
        
    }
    
}

// MARK: - StatsigServiceProtocol

final class MockStatsigService: StatsigServiceProtocol, @unchecked Sendable {

    internal let loggerName: String = "STATSIG_SERVICE"
    internal let loggerEmoji: String = "🚩"

    @Published var isReady: Bool = true
    var isReadyPublisher = CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()

    func setup(appDelegateService: AppDelegateServiceProtocol,
               environmentService: EnvironmentProviding,
               authProvider: AuthProviding) {}

    func identify(user: GPUser?) async {
        self.log(message: "identify: \(user?.id ?? "logged-out") (mock)")
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        self.log(message: "isEnabled: \(flag.displayName) [\(flag.rawValue)] → false (mock)")
        return flag.defaultValue
    }

    func value<Value>(_ parameter: DynamicConfigParameter<Value>) -> Value {
        self.log(message: "value: \(parameter.config.displayName).\(parameter.key) → default (mock)")
        return parameter.defaultValue
    }

}

// MARK: - UserDefaultsServiceProtocol

final class MockUserDefaultsService: UserDefaultsServiceProtocol, @unchecked Sendable {
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    var theme: AvailableTheme = .lightCyan
    var didCompleteOnboarding: Bool = false
    var didCompletePermission: Bool = false
    var lastViewedWhatsNewVersion: String?
    var didRateMyAppAlertShow: Bool = false
    var securityPinsDictionaryData: Data?
    var shouldHideScreenshots: Bool = false
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didCompletePermissionPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    var shouldHideScreenshotsPublisher = PassthroughSubject<Bool, Never>()
    
    func set(theme: AvailableTheme) {}
    func set(didCompleteOnboarding: Bool) {}
    func set(didCompletePermission: Bool) {}
    func set(lastViewedWhatsNewVersion: String?) {}
    func set(didRateMyAppAlertShow: Bool) {}
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
        container.appStoreSubscriptionService.register { @MainActor in MockAppStoreSubscriptionService() }
        container.launchScreenService.register { @MainActor in MockLaunchScreenService() }
        container.cameraPermissionService.register { @MainActor in MockCameraPermissionService() }
        container.mediaPermissionService.register { @MainActor in MockMediaPermissionService() }
        container.pushNotificationPermissionService.register { @MainActor in MockPushNotificationPermissionService() }
        container.appTrackingPermissionService.register { @MainActor in MockAppTrackingPermissionService() }
        container.microphonePermissionService.register { @MainActor in MockMicrophonePermissionService() }
        container.speechRecognitionPermissionService.register { @MainActor in MockSpeechRecognitionPermissionService() }
        container.viewLifecycleService.register { @MainActor in MockViewLifecycleService() }
        container.permissionsService.register { @MainActor in MockPermissionsService() }
        container.voiceTranscriptionService.register { @MainActor in MockVoiceTranscriptionService() }
        container.apiService.register { @MainActor in MockAPIService() }
        container.authService.register { @MainActor in MockAuthService() }
        container.statsigService.register { @MainActor in MockStatsigService() }
        container.rootStartupService.register { @MainActor in
            RootStartupService(
                launchService: container.launchScreenService(),
                environmentService: container.environmentService(),
                apiService: container.apiService(),
                authService: container.authService(),
                firebaseService: container.firebaseService(),
                appDelegateService: container.appDelegateService(),
                connectivityService: container.connectivityService(),
                viewLifecycleService: container.viewLifecycleService(),
                statsigService: container.statsigService()
            )
        }
        
    }
    
}

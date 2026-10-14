//
//  MockServiceAssembly.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/23/24.
//

import Foundation
import Combine
import AuthenticationServices
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FactoryKit
import StripePaymentSheet
import UserNotifications

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
        return MockCustomerModels.hostURL
    }

    func freshAccessToken() async throws(APIError) -> String? {
        return self.accessToken
    }

    private var currentUser: LLUser

    var customerAccount: CustomerAccount = MockCustomerModels.account
    var customerMemberships: [String: CustomerLocationMembership] = MockCustomerModels.memberships
    var customerAgeAcceptances: [String: [String: AgeGateAcceptance]] = [:]

    init() {

        let user = MockModels.MockUser.user1
        self.currentUser = user

    }

    // Health

    func getHealth() async throws {}

    // Users

    func getUser(id: String) async throws -> LLUser {

        let user = MockModels.MockUser.user1
        return user

    }

    func getUserProfile() async throws -> LLUser {

        let user = MockModels.MockUser.user1
        return user

    }

    func updateUser(user: LLUser) async throws {}
    func createUser(user: LLUser) async throws -> LLUser { user }
    func deleteUser(user: LLUser) async throws {}

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

// MARK: - AuthServiceProtocol

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {

    internal let loggerName: String = "AUTH_SERVICE"
    internal let loggerEmoji: String = "🪪"

    private let apiService: APIServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    @Published private(set) var currentUser: LLUser?
    var currentUserPublisher: AnyPublisher<LLUser?, Never> {
        return self.$currentUser.eraseToAnyPublisher()
    }

    var onInitialLoadCompleted = CurrentValueSubject<Bool, Never>(true)
    var onError = CurrentValueSubject<Error?, Never>(nil)

    init(apiService: APIServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.userDefaultsService = userDefaultsService
        self.currentUser = MockCustomerModels.user

    }

    func signup(firstName: String, lastName: String, email: String, password: String) async throws {

        let locationId = self.userDefaultsService.lastSelectedLocationId ?? MockCustomerModels.locationDetails.location.id
        let account = try await self.apiService.registerCustomerAccount(
            locationId: locationId,
            displayName: "\(firstName) \(lastName)".trimmed()
        )
        try Task.checkCancellation()

        self.currentUser = LLUser(customerAccount: account, externalId: MockCustomerModels.externalId, email: email)

    }

    func login(email: String, password: String) async throws {

        let account = try await self.apiService.getCustomerAccount()
        try Task.checkCancellation()

        self.currentUser = LLUser(customerAccount: account, externalId: MockCustomerModels.externalId, email: email)

    }

    func handleAppleSignupOrLogin(currentNonce: String?, authorization: ASAuthorization, isLogin: Bool) async throws {
        try await login(email: MockModels.MockUser.user1.email, password: "")
    }

    func fetchUserInfoWithToken() async throws {
        try await reloadUser()
    }

    func reloadUser() async throws {

        guard let currentUser = self.currentUser else { return }

        let account = try await self.apiService.getCustomerAccount()
        try Task.checkCancellation()

        guard self.currentUser?.id == currentUser.id else { return }
        self.currentUser = LLUser(
            customerAccount: account,
            externalId: currentUser.externalId,
            email: currentUser.email
        )

    }

    func deleteUser() async throws {

        try await self.apiService.deleteCustomerAccount()
        try Task.checkCancellation()

        self.currentUser = nil

    }

    func updateEmail(_ email: String) async throws {

        guard let currentUser = self.currentUser else { return }

        self.currentUser = LLUser(
            id: currentUser.id,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            email: email,
            externalId: currentUser.externalId
        )

    }

    func resetPassword(email: String) async throws {}

    func logout() async throws {

        await self.userDefaultsService.logout()
        self.currentUser = nil

    }

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
    func setup(navigationService: NavigationService) {}

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
    func uploadImage(imageData: Data, bucket: Query.Bucket) async throws -> URL {
        MockCustomerModels.imageURL(seed: MockCustomerModels.externalId)
    }

}

// MARK: - LaunchScreenServiceProtocol

final class MockLaunchScreenService: LaunchScreenServiceProtocol, @unchecked Sendable {

    internal let loggerName: String = "LAUNCH_SERVICE"
    internal let loggerEmoji: String = "🚀"

    var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)
    func setState(_ state: LaunchScreenService.State) {
        self.onLaunchStateChanged.send(state)
    }

}

// MARK: - PushNotificationServiceProtocol

final class MockPushNotificationService: PushNotificationServiceProtocol, @unchecked Sendable {

    internal let loggerName: String = "PUSH_NOTIFICATIONS_SERVICE"
    internal let loggerEmoji: String = "🔔"

    func parsePushNotification(_ pushNotification: UNNotification?, isTapped: Bool) {}
    func parseRemoteNotification(_ pushNotification: UNNotification, isTapped: Bool) {}
    func setup(navigationService: NavigationService) {}

}

// MARK: - UserDefaultsServiceProtocol

final class MockUserDefaultsService: UserDefaultsServiceProtocol, @unchecked Sendable {

    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"

    var theme: AvailableTheme = .light
    var didRateMyAppAlertShow: Bool = false
    var securityPinsDictionaryData: Data?
    var shouldHideScreenshots: Bool = false

    var lastSelectedLocationId: String?
    let guestIdentityId = MockCustomerModels.guestIdentityId
    var ageVerificationApprovals: [String: [String]] = [:]
    var ageVerificationApprovalMetadata: [String: [String: AgeVerificationApproval]] = [:]
    var favoriteProductIds: Set<String> = []
    let favoriteProductIdsPublisher = CurrentValueSubject<Set<String>, Never>([])
    var cachedStoreBranding: StoreAppBranding?
    var customerTheme: Theme?

    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    var shouldHideScreenshotsPublisher = PassthroughSubject<Bool, Never>()

    func set(theme: AvailableTheme) {

        self.theme = theme
        self.themePublisher.send(theme)
        applyStoreTheme(branding: self.cachedStoreBranding)

    }
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

    // Keep real navigation, alerts, persistence, splash, and lifecycle behavior.
    // Install these overrides on Container.shared before any ViewModel resolves.
    @MainActor
    func assembleRuntime(container: Container) {

        container.analyticsService.register { @MainActor in MockAnalyticsService() }
        container.firebaseService.register { @MainActor in MockFirebaseService() }
        container.connectivityService.register { @MainActor in MockConnectivityService() }
        container.apiService.register { @MainActor in MockAPIService() }
        container.authService.register { @MainActor in
            MockAuthService(
                apiService: container.apiService(),
                userDefaultsService: container.userDefaultsService()
            )
        }

    }

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
        container.launchScreenService.register { @MainActor in MockLaunchScreenService() }
        container.viewLifecycleService.register { @MainActor in MockViewLifecycleService() }
        container.apiService.register { @MainActor in MockAPIService() }
        container.authService.register { @MainActor in
            MockAuthService(
                apiService: container.apiService(),
                userDefaultsService: container.userDefaultsService()
            )
        }
        container.tabBarNavigationService.register { @MainActor in TabBarNavigationService() }
        container.storeSessionService.register { @MainActor in
            StoreSessionService(
                apiService: container.apiService(),
                authService: container.authService(),
                userDefaultsService: container.userDefaultsService(),
                tabBarNavigationService: container.tabBarNavigationService()
            )
        }
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
                storeSessionService: container.storeSessionService()
            )
        }

    }

}

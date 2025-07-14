//
//  MockServiceAssembly.swift
//  GlowPro 
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
import Swinject

// MARK: - AnalyticsServiceProtocol

final class MockAnalyticsService: AnalyticsServiceProtocol {
    
    internal let loggerName: String = "ANALYTICS_SERVICE"
    internal let loggerEmoji: String = "📀"
        
    var currentUserId = CurrentValueSubject<String?, Never>(nil)
    
    @Published var sessionEvents: [EventData] = []
    var sessionEventsPublisher: AnyPublisher<[EventData], Never> {
        return self.$sessionEvents.eraseToAnyPublisher()
    }
    
    func identifyUser(_ userId: String?) {}
    func setUserProperty(_ key: String, value: String) {}
    func track(_ app: AppEvent) { print("Tracking App Event") }
    func track(screen: ScreenEvent) { print("Tracking Screen Event") }
    func track(error: ErrorEvent) { print("Tracking Error Event") }
    func logout() {}
    
}

// MARK: - MockAlertService

class MockAlertService: AlertServiceProtocol, ObservableObject {
    
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

final class MockAPIService: APIServiceProtocol {
    
    internal let loggerName: String = "API_SERVICE"
    internal let loggerEmoji: String = "🌐"
    
    var accessToken: String? = nil
    var deviceToken: String? = nil
    var environment: AppEnvironment? = nil
    
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(.localhost)
    }
    
    private var currentUser: GPUser?
    private var businesses: [Business] = []
    private var locations: [Location] = []
    private var employees: [Employee] = []
    
    // Health
    
    func getHealth() async throws {}
    
    // Users
    
    func getUser(id: String) async throws -> GPUser { .DUMMY_DATA() }
    func getUserProfile() async throws -> GPUser { .DUMMY_DATA() }
    func getFirebaseTokenForUser(email: String) async throws -> String { return "" }
    func updateUser(user: GPUser) async throws {}
    func createUser(user: GPUser) async throws -> GPUser { user }
    func deleteUser(user: GPUser) async throws {}
    
    // Device
    
    func registerDevice(token: String, userId: String) async throws {}
    
    // Business
    
    func getBusinesses() async throws -> [Business] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getBusiness(id: String) async throws -> Business {
        return .DUMMY_DATA()
    }
    
    func deleteBusiness(id: String) async throws {}
    
    // Locations
    
    func getLocations() async throws -> [Location] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getLocations(businessId: String) async throws -> [Location] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getLocation(id: String) async throws -> Location {
        return .DUMMY_DATA()
    }
    
    func deleteLocation(id: String) async throws {}
    
    // Employees
    
    func getEmployees(businessId: String) async throws -> [Employee] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getEmployees(locationId: String) async throws -> [Employee] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getEmployee(id: String) async throws -> Employee {
        return .DUMMY_DATA()
    }
    
    func deleteEmployee(id: String) async throws {}
    
    // Clients
    
    func getClients(businessId: String) async throws -> [Client] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getClients(locationId: String) async throws -> [Client] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getClients(employeeId: String) async throws -> [Client] {
        return [.DUMMY_DATA(), .DUMMY_DATA(), .DUMMY_DATA()]
    }
    
    func getClient(id: String) async throws -> Client {
        return .DUMMY_DATA()
    }
    
    func deleteClient(id: String) async throws {}

}

// MARK: - AppDelegateServiceProtocol

class MockAppDelegateService: AppDelegateServiceProtocol {
    
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

class MockAppTrackingPermissionService: AppTrackingPermissionServiceProtocol {
    
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

final class MockAuthService: AuthServiceProtocol {
    
    internal let loggerName: String = "AUTH_SERVICE"
    internal let loggerEmoji: String = "🪪"
    
    var currentUser: GPUser? = .DUMMY_DATA()
    var currentUserPublisher = CurrentValueSubject<GPUser?, Never>(nil).eraseToAnyPublisher()
    var onInitialLoadCompleted = CurrentValueSubject<Bool, Never>(false)
    var onError = CurrentValueSubject<Error?, Never>(nil)
    
    func signup(name: String, email: String, password: String) async throws {
        self.currentUser = .DUMMY_DATA()
    }
    
    func login(email: String, password: String) async throws {
        self.currentUser = .DUMMY_DATA()
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

class MockImpersonateService: ImpersonateServiceProtocol {
    
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
    
}

// MARK: - CameraPermissionServiceProtocol

class MockCameraPermissionService: CameraPermissionServiceProtocol {
    
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

class MockConnectivityService: ConnectivityServiceProtocol {
    
    internal let loggerName: String = "CONNECTIVITY_SERVICE"
    internal let loggerEmoji: String = "📡"
    
    var onHasNetworkConnection = CurrentValueSubject<Bool, Never>(true)
    func setNetworkConnection(connection: Bool) {
        
    }
    
}

// MARK: - DeeplinkServiceProtocol

class MockDeeplinkService: DeeplinkServiceProtocol {
    
    internal let loggerName: String = "DEEPLINK_SERVICE"
    internal let loggerEmoji: String = "🔗"
    
    func handle(url: URL) {}
    func setup(mainViewModel: MainViewModel?, tabBarNavigationService: TabBarNavigationService) {}
    
}

// MARK: - EnvironmentServiceProtocol

class MockEnvironmentService: EnvironmentServiceProtocol {
    
    internal let loggerName: String = "ENVIRONMENT_SERVICE"
    internal let loggerEmoji: String = "♻️"
    
    var environment: AppEnvironment? = .development
    var environmentPublisher = CurrentValueSubject<AppEnvironment?, Never>(nil).eraseToAnyPublisher()
    
    func setEnvironment(_ environment: AppEnvironment) {}
    
}

// MARK: - FirebaseServiceProtocol

final class MockFirebaseService: FirebaseServiceProtocol {
    
    internal let loggerName: String = "FIREBASE_SERVICE"
    internal let loggerEmoji: String = "🔥"
    
    var user: FirebaseAuth.User? = nil
    var userPublisher = CurrentValueSubject<FirebaseAuth.User?, Never>(nil).eraseToAnyPublisher()
    var currentAccessToken: String? = nil
    var currentAccessTokenPublisher = CurrentValueSubject<String?, Never>(nil).eraseToAnyPublisher()
    
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

class MockLaunchScreenService: LaunchScreenServiceProtocol {
    
    internal let loggerName: String = "LAUNCH_SERVICE"
    internal let loggerEmoji: String = "🚀"
    
    var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)
    func setState(_ state: LaunchScreenService.State) {}
    
}

// MARK: - MediaPermissionServiceProtocol

class MockMediaPermissionService: MediaPermissionServiceProtocol {
    
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

class MockPermissionsService: PermissionsServiceProtocol {
    
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

class MockPushNotificationPermissionService: PushNotificationPermissionServiceProtocol {
    
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

class MockPushNotificationService: PushNotificationServiceProtocol {
    
    internal let loggerName: String = "PUSH_NOTIFICATIONS_SERVICE"
    internal let loggerEmoji: String = "🔔"
    
    func parsePushNotification(_ pushNotification: UNNotification?, isTapped: Bool) {}
    func setup(tabBarNavigationService: TabBarNavigationService) {}
    
}

// MARK: - UserDefaultsServiceProtocol

final class MockUserDefaultsService: UserDefaultsServiceProtocol {
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    var theme: AvailableTheme = .goldNavy
    var didCompleteOnboarding: Bool = false
    var didCompletePermission: Bool = false
    var lastViewedWhatsNewVersion: String?
    var didRateMyAppAlertShow: Bool = false
    var impersonatingUserData: Data?
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didCompletePermissionPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var impersonatingUserDataPublisher = PassthroughSubject<Data?, Never>()
    
    
    func set(theme: AvailableTheme) {}
    func set(didCompleteOnboarding: Bool) {}
    func set(didCompletePermission: Bool) {}
    func set(lastViewedWhatsNewVersion: String?) {}
    func set(didRateMyAppAlertShow: Bool) {}
    func set(impersonatedUser: ImpersonatingUser?) {}
    func logout() async {}
    
}

// MARK: - ViewLifecycleServiceProtocol

class MockViewLifecycleService: ViewLifecycleServiceProtocol {
    
    internal let loggerName: String = "VIEW_LIFECYCLE_SERVICE"
    internal let loggerEmoji: String = "🔁"
    
    var onShouldReloadView = CurrentValueSubject<Int, Never>(0)
    var onDidEnterBackground = CurrentValueSubject<String?, Never>(nil)
    var onDidBecomeActive = CurrentValueSubject<String?, Never>(nil)
    var onWillEnterForeground = CurrentValueSubject<String?, Never>(nil)
    
    func reload(for key: ViewLifecycleKey) {}
    func reloadAll() {}
    func publisher(for key: ViewLifecycleKey) -> AnyPublisher<Void, Never> { return PassthroughSubject().eraseToAnyPublisher() }
    
}

// MARK: - Mock Service Assembly

final class MockServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(EnvironmentServiceProtocol.self) { _ in MockEnvironmentService() }.inObjectScope(.container)
        container.register(AlertServiceProtocol.self) { _ in MockAlertService() }.inObjectScope(.container)
        container.register(AnalyticsServiceProtocol.self) { _ in MockAnalyticsService() }.inObjectScope(.container)
        container.register(AppDelegateServiceProtocol.self) { _ in MockAppDelegateService() }.inObjectScope(.container)
        container.register(DeeplinkServiceProtocol.self) { _ in MockDeeplinkService() }.inObjectScope(.container)
        container.register(FirebaseServiceProtocol.self) { _ in MockFirebaseService() }.inObjectScope(.container)
        container.register(UserDefaultsServiceProtocol.self) { _ in MockUserDefaultsService() }.inObjectScope(.container)
        container.register(ConnectivityServiceProtocol.self) { _ in MockConnectivityService() }.inObjectScope(.container)
        container.register(PushNotificationServiceProtocol.self) { _ in MockPushNotificationService() }.inObjectScope(.container)
        container.register(LaunchScreenServiceProtocol.self) { _ in MockLaunchScreenService() }.inObjectScope(.container)
        container.register(CameraPermissionServiceProtocol.self) { _ in MockCameraPermissionService() }.inObjectScope(.container)
        container.register(MediaPermissionServiceProtocol.self) { _ in MockMediaPermissionService() }.inObjectScope(.container)
        container.register(PushNotificationPermissionServiceProtocol.self) { _ in MockPushNotificationPermissionService() }.inObjectScope(.container)
        container.register(AppTrackingPermissionServiceProtocol.self) { _ in MockAppTrackingPermissionService() }.inObjectScope(.container)
        container.register(ViewLifecycleServiceProtocol.self) { _ in MockViewLifecycleService() }.inObjectScope(.container)
        container.register(PermissionsServiceProtocol.self) { _ in MockPermissionsService() }.inObjectScope(.container)
        container.register(APIServiceProtocol.self) { _ in MockAPIService() }.inObjectScope(.container)
        container.register(AuthServiceProtocol.self) { _ in MockAuthService() }.inObjectScope(.container)
        container.register(ImpersonateServiceProtocol.self.self) { _ in MockImpersonateService() }.inObjectScope(.container)
        
    }
    
}

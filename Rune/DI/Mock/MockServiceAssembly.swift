//
//  MockServiceAssembly.swift
//  GentlePath
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

class MockAnalyticsService: AnalyticsServiceProtocol {
        
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
    
    @Published var alerts: [Alert] = []
    
    var alertsPublisher: AnyPublisher<[Alert], Never> {
        return self.$alerts.eraseToAnyPublisher()
    }
    
    @Published var requestedToDeleteAlert = false
    var requestedToDeleteAlertPublisher: AnyPublisher<Bool, Never> {
        return self.$requestedToDeleteAlert.eraseToAnyPublisher()
    }
    
    func showAlert(_ alert: Alert) {
        self.alerts.append(alert)
    }
    
    func dismissAlert(_ alert: Alert) {
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

class MockAPIService: APIServiceProtocol {
    
    var accessToken: String? = nil
    var deviceToken: String? = nil
    var environment: AppEnvironment? = nil
    var logger: RuneLogger = .service(.mockAPI)
    
    var hostURL: String {
        return Constants.URLs.urlForEnvironment(.localhost)
    }
    
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

}

// MARK: - AppDelegateServiceProtocol

class MockAppDelegateService: AppDelegateServiceProtocol {
    
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

class MockAuthService: AuthServiceProtocol {
    
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
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - ConnectivityServiceProtocol

class MockConnectivityService: ConnectivityServiceProtocol {
    
    var onHasNetworkConnection = CurrentValueSubject<Bool, Never>(true)
    func setNetworkConnection(connection: Bool) {
        
    }
    
}

// MARK: - DeeplinkServiceProtocol

class MockDeeplinkService: DeeplinkServiceProtocol {
    
    func handle(url: URL) {}
    func setup(mainViewModel: MainViewModel?, tabBarNavigationService: TabBarNavigationService) {}
    
}

// MARK: - EnvironmentServiceProtocol

class MockEnvironmentService: EnvironmentServiceProtocol {
    
    var environment: AppEnvironment? = .development
    var environmentPublisher = CurrentValueSubject<AppEnvironment?, Never>(nil).eraseToAnyPublisher()
    
    func setEnvironment(_ environment: AppEnvironment) {}
    
}

// MARK: - FirebaseServiceProtocol

class MockFirebaseService: FirebaseServiceProtocol {
    
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
    
    var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)
    func setState(_ state: LaunchScreenService.State) {}
    
}

// MARK: - MediaPermissionServiceProtocol

class MockMediaPermissionService: MediaPermissionServiceProtocol {
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - PermissionsServiceProtocol

class MockPermissionsService: PermissionsServiceProtocol {
    
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
    
    var permissionGranted: Bool = false
    var permissionGrantedPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    func requestPermissionIfNeeded() {}
    func requestPermission() {}
    
}

// MARK: - PushNotificationServiceProtocol

class MockPushNotificationService: PushNotificationServiceProtocol {
    
    func parsePushNotification(_ pushNotification: UNNotification?, isTapped: Bool) {}
    func setup(tabBarNavigationService: TabBarNavigationService) {}
    
}

// MARK: - UserDefaultsServiceProtocol

class MockUserDefaultsService: UserDefaultsServiceProtocol {
    
    var theme: AvailableTheme = .goldNavy
    var didCompleteOnboarding: Bool = false
    var didShowPermissionScreen: Bool = false
    var lastViewedWhatsNewVersion: String?
    var didRateMyAppAlertShow: Bool = false
    var impersonatingUserData: Data?
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didShowPermissionScreenPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var impersonatingUserDataPublisher = PassthroughSubject<Data?, Never>()
    
    
    func set(theme: AvailableTheme) {}
    func set(didCompleteOnboarding: Bool) {}
    func set(didShowPermissionScreen: Bool) {}
    func set(lastViewedWhatsNewVersion: String?) {}
    func set(didRateMyAppAlertShow: Bool) {}
    func set(impersonatedUser: ImpersonatingUser?) {}
    func logout() async {}
    
}

// MARK: - ViewLifecycleServiceProtocol

class MockViewLifecycleService: ViewLifecycleServiceProtocol {
    
    var onShouldReloadView = CurrentValueSubject<Int, Never>(0)
    var onDidEnterBackground = CurrentValueSubject<String?, Never>(nil)
    var onDidBecomeActive = CurrentValueSubject<String?, Never>(nil)
    var onWillEnterForeground = CurrentValueSubject<String?, Never>(nil)
    
    func triggerReload() {}
    
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

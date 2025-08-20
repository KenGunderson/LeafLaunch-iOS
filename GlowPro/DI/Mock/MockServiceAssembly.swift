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
    
    private var currentUser: GPUser
    private var businesses: [Business]
    private var locations: [Location]
    private var employees: [Employee]
    private var clients: [Client]
    private var workspaces: [Workspace] = []
    private var media: [Media]
    
    init() {
        
        self.businesses = MockModels.allBusinesses
        self.locations = MockModels.allLocations
        self.employees = MockModels.allEmployees
        self.clients = MockModels.allClients
        self.workspaces = MockModels.allWorkspaces
        self.media = MockModels.allMedia
        
        var user = MockModels.MockUser.user1
        user.businesses = self.businesses
        
        self.currentUser = user
        
    }
    
    // Health
    
    func getHealth() async throws {}
    
    // Users
    
    func getUser(id: String) async throws -> GPUser {
        
        var user = MockModels.MockUser.user1
        user.businesses = self.businesses
        
        return user
        
    }
    
    func getUserProfile() async throws -> GPUser {
        
        var user = MockModels.MockUser.user1
        user.businesses = self.businesses
        
        return user
        
    }
    
    func getFirebaseTokenForUser(email: String) async throws -> String { return "MOCK_TOKEN" }
    func updateUser(user: GPUser) async throws {}
    func createUser(user: GPUser) async throws -> GPUser { user }
    func deleteUser(user: GPUser) async throws {}
    
    // Device
    
    func registerDevice(token: String, userId: String) async throws {}
    
    // Business
    
    func getBusinesses() async throws -> [Business] {
        
        var businesses: [Business] = []
        
        for business in self.businesses {
            
            let fetchedBusiness = try await getBusiness(id: business.id)
            businesses.append(fetchedBusiness)
            
        }
        
        return businesses
        
    }
    
    func getBusiness(id: String) async throws -> Business {
        
        var business = self.businesses.filter { $0.id == id }.first ?? .DUMMY_DATA()
        let clients = self.clients.filter { $0.employee.businessId == id }
        let employees = self.employees.filter { $0.businessId == id }
        let locations = self.locations.filter { $0.businessId == id }
        let media = self.media.filter { $0.businessId == id }
        
        business.clientsCount = clients.count
        business.employees = employees
        business.locations = locations
        business.media = media
        
        return business
        
    }
    
    func deleteBusiness(id: String) async throws {
        return self.businesses.removeAll { $0.id == id }
    }
    
    func createBusiness(business: Business) async throws -> Business {
        
        self.businesses.append(business)
        return business
        
    }
    
    func updateBusiness(business: Business) async throws {
        
        if let index = self.businesses.firstIndex(where: { $0.id == business.id }) {
            self.businesses[index] = business
        }
        
    }
    
    func deleteLocation(id: String) async throws {
        return self.locations.removeAll { $0.id == id }
    }
    
    // Locations
    
    func getLocations() async throws -> [Location] {
        return self.locations
    }
    
    func getLocations(businessId: String) async throws -> [Location] {
        return self.locations.filter { $0.businessId == businessId }
    }
    
    func getLocation(id: String) async throws -> Location {
        return self.locations.filter { $0.id == id }.first ?? .DUMMY_DATA()
    }
    
    func createLocation(location: Location) async throws -> Location {
        
        self.locations.append(location)
        return location
        
    }
    
    func updateLocation(location: Location) async throws {
     
        if let index = self.locations.firstIndex(where: { $0.id == location.id }) {
            self.locations[index] = location
        }
        
    }
    
    // Workspaces
    
    func getWorkspaces() async throws -> [Workspace] {
        
        var workspaces: [Workspace] = []
        
        let currentUserId = self.currentUser.id
        let ownedBusinesses = self.businesses.filter { $0.owner.id == currentUserId }
        let allEmployeeRoles = self.employees.filter { $0.userId == currentUserId }
        
        for business in ownedBusinesses {
            
            let businessDetails = try await self.getBusiness(id: business.id)
            
            let ownedWorkspace = Workspace(
                id: "owner_workspace",
                name: businessDetails.name,
                isOwner: true,
                locations: businessDetails.locations
            )
            
            workspaces.append(ownedWorkspace)
            
        }
        
        for employee in allEmployeeRoles {
            
            let businessDetails = try await self.getBusiness(id: employee.businessId)
            let location = try await self.getLocation(id: employee.locationId)
            
            let employedWorkspace = Workspace(
                id: UUID().uuidString,
                name: businessDetails.name,
                isOwner: false,
                locations: [location]
            )
            
            workspaces.append(employedWorkspace)
            
        }
        
        return workspaces
        
    }
    
    // Employees
    
    func getEmployees(businessId: String) async throws -> [Employee] {
        return self.employees.filter { $0.businessId == businessId }
    }
    
    func getEmployees(locationId: String) async throws -> [Employee] {
        return self.employees
    }
    
    func getEmployeeByUserIdForLocation(userId: String, locationId: String) async throws -> Employee {
        
        if let employee = self.employees.first(where: { $0.locationId == locationId && $0.userId == userId }) {
            return employee
        }
        
        throw APIError.serverError(statusCode: 401, errorMessage: "Employee Not Found")
        
    }
    
    func getEmployee(id: String) async throws -> Employee {
        return self.employees.first ?? .DUMMY_DATA()
    }
    
    func createEmployee(employee: Employee) async throws -> Employee {
        
        self.employees.append(employee)
        return employee
        
    }
    
    func updateEmployee(employee: Employee) async throws {
        
        if let index = self.employees.firstIndex(where: { $0.id == employee.id }) {
            self.employees[index] = employee
        }
        
    }
    
    func deleteEmployee(id: String) async throws {
        self.employees.removeAll { $0.id  == id }
    }
    
    // Employee Invites
    
    func getEmployeeInvites(businessId: String) async throws -> [EmployeeInvite] {
        
        if let business = self.businesses.first(where: { $0.id == businessId }) {
            return business.employeeInvites
        }
        
        return []
        
    }
    
    func getPendingInvitesForUser() async throws -> [EmployeeInvite] {
        
        let allEmployeeInvites: [EmployeeInvite] = self.businesses.flatMap(\.employeeInvites)
        return allEmployeeInvites.filter { $0.name == currentUser.name }
        
    }
    
    func acceptEmployeeInvite(invite: EmployeeInvite) async throws {
        
        if let businessIndex = self.businesses.firstIndex(where: { $0.name == invite.businessName }),
           let employeeInviteIndex = self.businesses[businessIndex].employeeInvites.firstIndex(of: invite) {
            
            let business = self.businesses[businessIndex]
            let invitedLocations = invite.locations.isEmpty ? business.locations : invite.locations
            
            for location in invitedLocations {
                
                let employee = Employee(
                    id: UUID().uuidString,
                    businessId: business.id,
                    locationId: location.id,
                    userId: self.currentUser.id,
                    name: invite.name,
                    email: invite.email,
                    phone: "",
                    role: invite.role ?? .employee
                )
                
                self.employees.append(employee)
                
            }
            
            self.businesses[businessIndex].employeeInvites.remove(at: employeeInviteIndex)
            self.currentUser.businesses.append(self.businesses[businessIndex])
            
        }
        
    }
    
    func declineEmployeeInvite(invite: EmployeeInvite) async throws {
        
        if let businessIndex = self.businesses.firstIndex(where: { $0.name == invite.businessName }),
           let employeeInviteIndex = self.businesses[businessIndex].employeeInvites.firstIndex(of: invite) {
            
            self.businesses[businessIndex].employeeInvites.remove(at: employeeInviteIndex)
                
        }
        
    }
    
    func createEmployeeInvite(invite: EmployeeInvite) async throws {
        
        if let businessIndex = self.businesses.firstIndex(where: { $0.name == invite.businessName }) {
            self.businesses[businessIndex].employeeInvites.append(invite)
        }
        
    }
    
    func deleteEmployeeInvite(invite: EmployeeInvite) async throws {
        
        if let businessIndex = self.businesses.firstIndex(where: { $0.name == invite.businessName }),
           let employeeInviteIndex = self.businesses[businessIndex].employeeInvites.firstIndex(of: invite) {
            
            self.businesses[businessIndex].employeeInvites.remove(at: employeeInviteIndex)
                
        }
        
    }
    
    // Clients
    
    func getClients(businessId: String) async throws -> [Client] {
        return self.clients.filter { $0.employee.businessId == businessId }
    }
    
    func getClients(locationId: String) async throws -> [Client] {
        return self.clients.filter { $0.locationId == locationId }
    }
    
    func getClients(employeeId: String) async throws -> [Client] {
        return self.clients.filter { $0.employee.id == employeeId }
    }
    
    func getClient(id: String) async throws -> Client {
        return self.clients.filter { $0.id == id }.first ?? .DUMMY_DATA()
    }
    
    func createClient(client: Client,
                      locationId: String) async throws {
        
        if let locationIndex = self.locations.firstIndex(where: { $0.id == locationId }) {
            
            self.clients.append(client)
            self.locations[locationIndex].clients.append(client)
            
        }
        
    }

    func updateClient(client: Client) async throws {
        
        if let index = self.clients.firstIndex(where: { $0.id == client.id }) {
            self.clients[index] = client
        }
        
    }
    
    func deleteClient(id: String) async throws {
        self.clients.removeAll { $0.id == id }
    }
    
    // Media
    
    func getMedia(businessId: String) async throws -> [Media] {
        return self.media.filter { $0.businessId == businessId }
    }
    
    func getMedia(locationId: String) async throws -> [Media] {
        
        var media: [Media] = []
        
        for mediaItem in self.media {
            
            guard let clientId = mediaItem.clientId else { continue }
            
            let client = try await self.getClient(id: clientId)
            
            if client.locationId == locationId {
                media.append(mediaItem)
            }
            
        }
        
        return media
        
    }
    
    func getMedia(clientId: String) async throws -> [Media] {
        return self.media.filter { $0.clientId == clientId }
    }
    
    // System
    
    func getLegalInformation(context: String) -> [LegalItem] {
        
        return [
            
            .init(
                title: "General Information",
                sections: [
                    "This is the first section",
                    "This is the secone section",
                    "This is the third section",
                    "This is the fourth section"
                ]
            ),
            
                .init(
                    title: "General Information",
                    sections: [
                        "This is the first section",
                        "This is the secone section",
                        "This is the third section",
                        "This is the fourth section"
                    ]
                )
            
        ]
        
    }
    
    func getFrequentlyAskedQuestions() async throws -> [FAQViewModel.FAQItemSection] {
        return [

            .init(
                title: "General Questions",
                sections: [
                    .init(
                        question: "What is this app?",
                        answer: "This app helps beauty professionals manage their business, employees, clients, and media content all in one place."
                    ),
                    .init(
                        question: "Is there a free trial?",
                        answer: "Yes, new users can enjoy a 14-day free trial with access to all premium features."
                    ),
                    .init(
                        question: "Which platforms is the app available on?",
                        answer: "The app is available on iOS and Android devices, with a web version coming soon."
                    )
                ]
            ),

            .init(
                title: "Managing Your Business",
                sections: [
                    .init(
                        question: "How do I add a new employee?",
                        answer: "Go to the 'Employees' tab, tap the '+' icon, and fill in the employee’s details to send them an invite."
                    ),
                    .init(
                        question: "Can I assign roles to employees?",
                        answer: "Yes, each employee can be assigned a role such as Admin, Front Desk, or Stylist, each with different permissions."
                    ),
                    .init(
                        question: "What if my business has multiple locations?",
                        answer: "You can manage multiple locations from a single account and switch between them seamlessly."
                    )
                ]
            ),

            .init(
                title: "Media & Client Engagement",
                sections: [
                    .init(
                        question: "Can I edit photos within the app?",
                        answer: "Yes, our built-in editor includes filters, cropping, retouching, and watermarking tools."
                    ),
                    .init(
                        question: "How does media sharing to Instagram work?",
                        answer: "You can schedule posts and share directly to Instagram through our integrated social sharing feature."
                    ),
                    .init(
                        question: "Can clients favorite media?",
                        answer: "Yes, clients can favorite media, and you’ll be able to see which styles are most popular."
                    )
                ]
            )

        ]
    }


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
    
    private let apiService: APIServiceProtocol = MockAPIService()
    
    var currentUser: GPUser? = MockModels.MockUser.user1
    var currentUserPublisher = CurrentValueSubject<GPUser?, Never>(nil).eraseToAnyPublisher()
    var onInitialLoadCompleted = CurrentValueSubject<Bool, Never>(false)
    var onError = CurrentValueSubject<Error?, Never>(nil)
    
    func signup(firstName: String, lastName: String, email: String, password: String) async throws {
        self.currentUser = MockModels.MockUser.user1
    }
    
    func login(email: String, password: String) async throws {
        
        let businesses = try await apiService.getBusinesses()
        var currentUser = MockModels.MockUser.user1
        currentUser.businesses = businesses
        
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

final class MockActiveDestinationService: ActiveDestinationServiceProtocol {
    
    internal let loggerName: String = "ACTIVE_DESTINATION_SERVICE"
    internal let loggerEmoji: String = "🛩️"
    
    private let apiService: APIServiceProtocol = MockAPIService()
    private let analyticsService: AnalyticsServiceProtocol = MockAnalyticsService()
    
    @Published private(set) var activeDestination: ActiveDestination?
    var activeDestinationPublisher: AnyPublisher<ActiveDestination?, Never> {
        return self.$activeDestination.eraseToAnyPublisher()
    }
    
    func setActiveDestination(_ destination: ActiveDestination) {
        self.activeDestination = destination
    }
    
    func removeActiveDestination() {
        self.activeDestination = nil
    }
    
    func logout() {
        self.activeDestination = nil
    }
    
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
    func setup(mainViewModel: MainViewModel?, navigationService: NavigationService) {}
    
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
    func setup(navigationService: NavigationService) {}
    
}

// MARK: - UserDefaultsServiceProtocol

final class MockUserDefaultsService: UserDefaultsServiceProtocol {
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    var theme: AvailableTheme = .lightCyan
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
        container.register(ActiveDestinationServiceProtocol.self.self) { _ in MockActiveDestinationService() }.inObjectScope(.container)
        
    }
    
}

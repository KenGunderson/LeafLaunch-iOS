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
    
    func identifyUser(_ userId: String?) {}
    func setUserProperty(_ key: String, value: String) {}
    func track(_ app: AppEvent) { print("Tracking App Event") }
    func track(screen: ScreenEvent) { print("Tracking Screen Event") }
    func track(error: ErrorEvent) { print("Tracking Error Event") }
    func logout() {}
    
}

// MARK: - MockAlertService

final class MockAlertService: AlertServiceProtocol, ObservableObject {
    
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
    private var locationEmployees: [LocationEmployee]
    private var clients: [Client]
    private var workspaces: [Workspace] = []
    private var media: [Media]
    private var mediaTags: [MediaTag] = []
    private var activities: [Activity]
    private var notes: [Note] = []
    
    init() {
        
        self.businesses = MockModels.allBusinesses
        self.locations = MockModels.allLocations
        self.locationEmployees = MockModels.allLocationEmployees
        self.employees = MockModels.allEmployees
        self.clients = MockModels.allClients
        self.workspaces = MockModels.allWorkspaces
        self.media = MockModels.allMedia
        self.mediaTags = MockModels.allMediaTags
        self.activities = MockModels.allActivities
        self.notes = MockModels.allNotes
        
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
    
    func getBusinesses(userId: String) async throws -> [Business] {
        
        var businesses: [Business] = []
        
        for business in self.businesses {
            
            let fetchedBusiness = try await getBusiness(id: business.id)
            businesses.append(fetchedBusiness)
            
        }
        
        return businesses
        
    }
    
    func getBusiness(id: String) async throws -> Business {
        
        var business = self.businesses.filter { $0.id == id }.first ?? .DUMMY_DATA()
        let employees = self.employees.filter { $0.businessId == id }
        let locations = self.locations.filter { $0.businessId == id }
        let media = self.media.filter { $0.businessId == id }
        
        var totalClients: [Client] {
            
            var localClients: [Client] = []
            
            locations
                .forEach { location in
                    
                    self.clients.forEach { client in
                        
                        if client.locationId == location.id {
                            localClients.append(client)
                        }
                        
                    }
                    
                }
            
            return localClients
            
        }
        
        let totalLocationCount = business.totalLocationCount
        let totalEmployeeCount = employees.count
        let totalMediaCount = business.totalMediaCount
        let totalClientCount = totalClients
        
        var clients: [Client] = []
        
        for client in self.clients {
            
            let employeeId = client.employeeId ?? ""
            let employee = try await getEmployee(id: employeeId)
            
            if employee.businessId == business.id {
                clients.append(client)
            }
            
        }
        
        business.totalClientCount = clients.count
        business.employees = employees
        business.locations = locations
        business.media = media
        business.totalLocationCount = totalLocationCount
        business.totalEmployeeCount = totalEmployeeCount
        business.totalMediaCount = totalMediaCount
        business.totalClientCount = totalClientCount.count
        
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
        
        var location = self.locations.filter { $0.id == id }.first ?? .DUMMY_DATA()
        let clients = self.clients.filter { $0.locationId == id }
        let employees = self.locationEmployees.filter { $0.locationId == id }
        let media = self.media.filter { $0.locationId == id }
        
        let totalClientCount = clients.count
        let totalEmployeeCount = employees.count
        let totalMediaCount = media.count
        
        location.employees = employees
        location.clients = clients
        location.media = media
        location.totalClientCount = totalClientCount
        location.totalEmployeeCount = totalEmployeeCount
        location.totalMediaCount = totalMediaCount
        
        return location
        
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
        let allEmployeeRoles = self.locationEmployees.filter { $0.user.id == currentUserId }
        
        for business in ownedBusinesses {
            
            let businessDetails = try await self.getBusiness(id: business.id)
            
            let ownedWorkspace = Workspace(
                id: "owner_workspace",
                name: businessDetails.name,
                isOwner: true,
                roleLocations: businessDetails.locations.map { return .init(role: .owner, location: $0) }
            )
            
            workspaces.append(ownedWorkspace)
            
        }
        
        for employee in allEmployeeRoles {
            
            let location = try await self.getLocation(id: employee.locationId)
            let businessDetails = try await self.getBusiness(id: location.businessId)
            
            let employedWorkspace = Workspace(
                id: UUID().uuidString,
                name: businessDetails.name,
                isOwner: false,
                roleLocations: [.init(
                    role: employee.role,
                    location: location
                )]
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
        
        let pairs = self.locationEmployees.filter { $0.locationId == locationId }
        return pairs.compactMap { pair in self.employees.first { $0.id == pair.employeeId } }
        
    }
    
    func getEmployeeByUserIdForLocation(userId: String, locationId: String) async throws -> String {
        
        if let employee = self.locationEmployees.first(where: { $0.locationId == locationId && $0.user.id == userId }) {
            return employee.id
        }
        
        if let location = self.locations.filter({ $0.id == locationId }).first,
           let business = self.businesses.filter ({ $0.id == location.businessId }).first {
            
            return business.owner.id
            
        }
        
        
        throw APIError.serverError(statusCode: 401, errorMessage: "Employee Not Found")
        
    }
    
    func getEmployee(id: String) async throws -> Employee {
        return self.employees.filter { $0.id == id }.first ?? .DUMMY_DATA()
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
    
    // Location Employee
    
    func getLocationEmployee(employeeId: String,
                             locationId: String) async throws -> LocationEmployee {
        
        let locationEmployees = self.locationEmployees.filter({ $0.locationId == locationId && $0.employeeId == employeeId })
        
        if let locationEmployee = locationEmployees.first {
            return locationEmployee
        }
        
        return self.locationEmployees.first!
        
    }
    
    // Employee Invites
    
    func getEmployeeInvites(businessId: String) async throws -> [EmployeeInvite] {
        
        if let business = self.businesses.first(where: { $0.id == businessId }) {
            return business.employeeInvites
        }
        
        return []
        
    }
    
    func getPendingInvitesForUser(email: String) async throws -> [EmployeeInvite] {
        
        let allEmployeeInvites: [EmployeeInvite] = self.businesses.flatMap(\.employeeInvites)
        return allEmployeeInvites.filter { $0.name.firstName == currentUser.firstName }
        
    }
    
    func acceptEmployeeInvite(invite: EmployeeInvite) async throws {
        
        if let businessIndex = self.businesses.firstIndex(where: { $0.name == invite.businessName }),
           let employeeInviteIndex = self.businesses[businessIndex].employeeInvites.firstIndex(of: invite) {
            
            let business = self.businesses[businessIndex]
            
            let employee = Employee(
                id: UUID().uuidString,
                businessId: business.id,
                userId: currentUser.id,
                name: invite.name,
                email: invite.email,
                phoneNumber: currentUser.phoneNumber ?? ""
            )
            
            self.employees.append(employee)
            
            for location in invite.locationIds {
                
                let locationEmployee = LocationEmployee(
                    id: UUID().uuidString,
                    businessId: business.id,
                    locationId: location,
                    employeeId: employee.id,
                    user: currentUser,
                    role: invite.role ?? .employee
                )
                
                self.locationEmployees.append(locationEmployee)
                
            }
            
            self.businesses[businessIndex].employeeInvites.remove(at: employeeInviteIndex)
            self.currentUser.businesses?.append(self.businesses[businessIndex])
            
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
                
        var clients: [Client] = []
        
        for client in self.clients {
            
            let employeeId = client.employeeId ?? ""
            let employee = try await getEmployee(id: employeeId)
            
            if employee.businessId == businessId {
                clients.append(client)
            }
            
        }
        
        return clients
        
    }
    
    func getClients(locationId: String) async throws -> [Client] {
        return self.clients.filter { $0.locationId == locationId }
    }
    
    func getClients(employeeId: String) async throws -> [Client] {
        return self.clients.filter { $0.employeeId == employeeId }
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
    
    func getMedia(businessId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
        let media = self.media.filter { $0.businessId == businessId }
        
        return processMedia(
            media,
            sortingOption: sortingOption,
            tags: tags
        )
        
    }
    
    func getMedia(locationId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
        var media: [Media] = []
        
        for mediaItem in self.media {
            
            guard let clientId = mediaItem.clientId else { continue }
            
            let client = try await self.getClient(id: clientId)
            
            if client.locationId == locationId {
                media.append(mediaItem)
            }
            
        }
        
        return processMedia(
            media,
            sortingOption: sortingOption,
            tags: tags
        )
        
    }
    
    func getMedia(clientId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
        let media = self.media.filter { $0.clientId == clientId }
        
        return processMedia(
            media,
            sortingOption: sortingOption,
            tags: tags
        )
        
    }
    
    func getMedia(authorId: String,
                  sortingOption: MediaSortingOption?,
                  tags: [MediaTag]) async throws -> [Media] {
        
        let media = self.media.filter { $0.authorId == authorId }
        
        return processMedia(
            media,
            sortingOption: sortingOption,
            tags: tags
        )
        
    }
    
    func getMedia(id: String) async throws -> Media {
        return self.media.first(where: { $0.id == id }) ?? .DUMMY_DATA()
    }
    
    private func processMedia(_ media: [Media],
                              sortingOption: MediaSortingOption?,
                              tags: [MediaTag]) -> [Media] {
        
        var filtered = media
        
        if !tags.isEmpty {
            
            filtered = filtered.filter { media in
                !Set(tags).isDisjoint(with: media.tags)
            }
            
        }
        
        switch sortingOption {
        case .newest: filtered.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .oldest: filtered.sort { ($0.createdAt ?? .distantFuture) < ($1.createdAt ?? .distantFuture) }
        case .favorited: filtered = filtered.filter { $0.isFavorited }
        case .none: break
        }
        
        return filtered
        
    }
    
    func favoriteMedia(mediaId: String,
                       locationId: String) async throws {
        
        if let index = self.media.firstIndex(where: { $0.id == mediaId }) {
            
            let oldMedia = self.media[index]
            
            var newMedia = oldMedia
            newMedia.isFavorited = true
            
            self.media[index] = newMedia
            
        }
        
    }

    func unfavoriteMedia(mediaId: String,
                         locationId: String) async throws {
        
        if let index = self.media.firstIndex(where: { $0.id == mediaId }) {
            
            let oldMedia = self.media[index]
            
            var newMedia = oldMedia
            newMedia.isFavorited = false
            
            self.media[index] = newMedia
            
        }
        
    }
    
    func deleteMedia(mediaId: String) async throws {
        
        self.media
            .removeAll(where: { $0.id == mediaId })
        
    }
    
    // Media Tags
    
    func getMediaTags(businessId: String) async throws -> [MediaTag] {
        return self.mediaTags
    }
    
    func createTag(tag: String, businessId: String) async throws {
        
        let mediaTag = MediaTag(name: tag)
        self.mediaTags.append(mediaTag)
        
    }
    
    func deleteTag(mediaTagId: String) async throws {
        self.mediaTags.removeAll(where: { $0.id == mediaTagId })
    }
    
    // Media Tag Relations
    
    func createMediaTagForMedia(mediaId: String,
                                mediaTagId: String) async throws {
        
        if let index = self.media.firstIndex(where: { $0.id == mediaId }),
           let mediaTag = self.mediaTags.first(where: { $0.id == mediaTagId }){
            
            self.media[index].tags.append(mediaTag)
            
        }
        
    }
    
    func deleteMediaTagFromMedia(mediaId: String,
                                 mediaTagId: String) async throws {
        
        if let index = self.media.firstIndex(where: { $0.id == mediaId }) {
            self.media[index].tags.removeAll(where: { $0.id == mediaTagId })
        }
        
    }
    
    // Activity
    
    func getActivitiy(businessId: String) async throws -> [Activity] {
        
        var activities: [Activity] = []
        
        for activity in self.activities {
                        
            let employee = try await self.getEmployee(id: activity.authorId)
            
            if employee.businessId == businessId {
                activities.append(activity)
            }
            
        }
        
        return activities
        
    }
    
    func getActivitiy(locationId: String) async throws -> [Activity] {
        
        var activities: [Activity] = []
        
        for activity in self.activities {
                        
            let locationEmployee = try await self.getLocationEmployee(employeeId: activity.authorId, locationId: locationId)
            
            if locationEmployee.locationId == locationId {
                activities.append(activity)
            }
            
        }
        
        return activities
        
    }
    
    func getActivitiy(employeeId: String) async throws -> [Activity] {
        return self.activities.filter { $0.authorId == employeeId }
    }
    
    func getActivitiy(clientId: String) async throws -> [Activity] {
        return self.activities.filter { $0.clientId == clientId }
    }
    
    // Upload Media
    
    func uploadMedia(uploadMedia: UploadMedia) async throws -> String {
        return "URL_TO_UPLOADED_MEDIA"
    }
    
    // Notes
    
    func getNotes(clientId: String) async throws -> [Note] {
        return self.notes.filter { $0.clientId == clientId }
    }
    
    func getNote(id: String) async throws -> Note {
        
        if let note = self.notes.first(where: { $0.id == id }) {
            return note
        }
        
        return .DUMMY_DATA()
        
    }
    
    func createNote(note: Note) async throws {
        self.notes.append(note)
    }
    
    func updateNote(note: Note) async throws {
        
        if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
            self.notes[index] = note
        }
        
    }
    
    func deleteNote(id: String) async throws {
        self.notes.removeAll(where: { $0.id == id })
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
    
    // Feature Requests
    
    func submitFeatureRequest(userId: String,
                              request: String) async throws {
        
    }

}

// MARK: - AppDelegateServiceProtocol

final class MockAppDelegateService: AppDelegateServiceProtocol {
    
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

final class MockAppTrackingPermissionService: AppTrackingPermissionServiceProtocol {
    
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
        
        var currentUser = MockModels.MockUser.user1
        let businesses = try await apiService.getBusinesses(userId: currentUser.id)
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
    
    private(set) var isOwner: Bool = true
    private(set) var isManager: Bool = true
    private(set) var isOwnerOrManager: Bool = true
    private(set) var role: Role? = .owner
    internal var business: Business? = MockModels.MockBusiness.business1
    internal var businessId: String? = MockModels.ID.business1
    internal var locationEmployee: LocationEmployee? = MockModels.MockLocationEmployee.locationEmployee1
    
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
    
    func refresh() {}
    
}

// MARK: IMPERSONATE

final class MockImpersonateService: ImpersonateServiceProtocol {
    
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

final class MockCameraPermissionService: CameraPermissionServiceProtocol {
    
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

final class MockConnectivityService: ConnectivityServiceProtocol {
    
    internal let loggerName: String = "CONNECTIVITY_SERVICE"
    internal let loggerEmoji: String = "📡"
    
    var onHasNetworkConnection = CurrentValueSubject<Bool, Never>(true)
    func setNetworkConnection(connection: Bool) {
        
    }
    
}

// MARK: - DeeplinkServiceProtocol

final class MockDeeplinkService: DeeplinkServiceProtocol {
    
    internal let loggerName: String = "DEEPLINK_SERVICE"
    internal let loggerEmoji: String = "🔗"
    
    func handle(url: URL) {}
    func setup(mainViewModel: MainViewModel?, navigationService: NavigationService) {}
    
}

// MARK: - EnvironmentServiceProtocol

final class MockEnvironmentService: EnvironmentServiceProtocol {
    
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
    
    var isNewUserContext: Bool = false
    
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

final class MockLaunchScreenService: LaunchScreenServiceProtocol {
    
    internal let loggerName: String = "LAUNCH_SERVICE"
    internal let loggerEmoji: String = "🚀"
    
    var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)
    func setState(_ state: LaunchScreenService.State) {}
    
}

// MARK: - MediaPermissionServiceProtocol

final class MockMediaPermissionService: MediaPermissionServiceProtocol {
    
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

final class MockPermissionsService: PermissionsServiceProtocol {
    
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

final class MockPushNotificationPermissionService: PushNotificationPermissionServiceProtocol {
    
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

final class MockPushNotificationService: PushNotificationServiceProtocol {
    
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
    var didViewChecklistCompletionSheet: Bool = false
    var lastViewedWhatsNewVersion: String?
    var didRateMyAppAlertShow: Bool = false
    var impersonatingUserData: Data?
    var securityPinsDictionaryData: Data?
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didCompletePermissionPublisher = PassthroughSubject<Bool, Never>()
    var didViewChecklistCompletionSheetPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var impersonatingUserDataPublisher = PassthroughSubject<Data?, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    
    func set(theme: AvailableTheme) {}
    func set(didCompleteOnboarding: Bool) {}
    func set(didCompletePermission: Bool) {}
    func set(didViewChecklistCompletionSheet: Bool) {}
    func set(lastViewedWhatsNewVersion: String?) {}
    func set(didRateMyAppAlertShow: Bool) {}
    func set(impersonatedUser: ImpersonatingUser?) {}
    func set(securityPin: String?, businessId: String) {}
    
    func getSecurityPinForBusinessId(_ businessId: String) -> String? { return nil }
    
    func logout() async {}
    
}

// MARK: - CameraServiceProtocol

final class MockCameraService: CameraServiceProtocol {
    
    internal let loggerName: String = "CAMERA_SERVICE"
    internal let loggerEmoji: String = "📷"
    
    var session: AVCaptureSession = .init()
    
    @Published internal var flashMode: CameraFlashMode = .on
    var flashModePublisher: AnyPublisher<CameraFlashMode, Never>  {
        return self.$flashMode.eraseToAnyPublisher()
    }
    
    @Published internal var zoomFactor: CGFloat = 1
    var zoomFactorPublisher: AnyPublisher<CGFloat, Never>  {
        return self.$zoomFactor.eraseToAnyPublisher()
    }
    
    func configure() throws {
        //
    }
    
    func start() {}
    func stop() {}
    func teardown() {}
    
    func capturePhoto(_ completion: @escaping (Result<UIImage, any Error>) -> Void) {}
    
    func setFlashMode(_ mode: CameraFlashMode) {
        flashMode = mode
    }
    
    func toggleFlash() {
        
        let shouldTurnOn = self.flashMode == .auto || self.flashMode == .off
        self.flashMode = shouldTurnOn ? .on : .off
        
    }
    
    func zoom(by multiplier: CGFloat,
              animated: Bool) {
        
        self.zoomFactor += multiplier
        self.log(message: "Zoomed by multiplier: \(multiplier)")
        self.log(message: "Total Zoom Factor: \(self.zoomFactor)")
        
    }
    
    func setZoom(factor: CGFloat,
                 animated: Bool,
                 rampRate: Float) {
        
        self.zoomFactor = factor
        self.log(message: "Zoomed by factor: \(factor)")
        self.log(message: "Total Zoom Factor: \(self.zoomFactor)")
        
    }
    
}

// MARK: - ViewLifecycleServiceProtocol

final class MockViewLifecycleService: ViewLifecycleServiceProtocol {
    
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

final class MockMediaTransferService: MediaTransferServiceProtocol {
 
    internal let loggerName: String = "MEDIA_TRANSFER_SERVICE"
    internal let loggerEmoji: String = "🚛"
    
    var mediaPublisher = PassthroughSubject<[Media], Never>()
    var mediaURLsPublisher = PassthroughSubject<[URL], Never>()
    
    func sendMedia(_ media: [Media]) {
        self.mediaPublisher.send(media)
    }
    
    func sendURLs(_ url: [URL]) {
        self.mediaURLsPublisher.send(url)
    }
    
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
        container.register(CameraServiceProtocol.self.self) { _ in MockCameraService() }.inObjectScope(.transient)
        container.register(MediaTransferServiceProtocol.self.self) { _ in MediaTransferService() }.inObjectScope(.transient)
    }
    
}

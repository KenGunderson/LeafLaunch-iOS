//
//  ClientCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import Combine
import Foundation

final class ClientCreateEditViewModel: ViewModel {
    
    internal let loggerName: String = "CLIENT_CREATE_EDIT_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var business: Business?
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var dateOfBirth: Date = .now
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.firstName.isEmpty &&
            !self.lastName.isEmpty
        )
        
    }
    
    private var locationId: String?
    private var clientId: String?

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var navTitle: String {
        return self.clientId == nil ? "Create Client" : "Edit Client"
    }
    
    var saveButtonTitle: String {
        return self.clientId == nil ? "Create" : "Save"
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(locationId: String? = nil,
               clientId: String? = nil) -> Self {
        
        self.locationId = locationId
        self.clientId = clientId
        
        return self
        
    }
    
    func loadData() {
        
        guard let clientId else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let client = try await self.apiService.getClient(id: clientId)
                
                await MainActor.run {
                    
                    self.firstName = client.firstName
                    self.lastName = client.lastName
                    self.phone = client.phone ?? ""
                    self.email = client.email ?? ""
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("client"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func saveOrUpdate() {
        
        if self.clientId == nil {
            save()
        } else {
            update()
        }
        
    }
    
    private func save() {
        
        guard let currentUser = self.authService.currentUser else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let employeeId = try await self.apiService.getEmployeeByUserIdForLocation(
                    userId: currentUser.id,
                    locationId: self.locationId ?? ""
                )
                
                let isValidDateOfBirth = !self.dateOfBirth.isToday
                let dateOfBirth = isValidDateOfBirth ? self.dateOfBirth.ISO8601Format() : nil
                
                let newClient = Client(
                    id: UUID().uuidString,
                    firstName: self.firstName,
                    lastName: self.lastName,
                    email: self.email,
                    phone: self.phone,
                    dateOfBirth: dateOfBirth,
                    locationId: self.locationId ?? "",
                    employeeId: employeeId
                )
                
                try await self.apiService
                    .createClient(
                        client: newClient,
                        locationId: self.locationId ?? ""
                    )
                
                self.viewLifecycleService
                    .reload(for: .clientList)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Client created successfully.",
                        action: {
                            self.navigationService?.pop()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while saving your client. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    private func update() {
        
        guard let clientId else { return }
        guard let currentUser = self.authService.currentUser else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let employeeId = try await self.apiService.getEmployeeByUserIdForLocation(
                    userId: currentUser.id,
                    locationId: self.locationId ?? ""
                )
                
                let isValidDateOfBirth = !self.dateOfBirth.isToday
                let dateOfBirth = isValidDateOfBirth ? self.dateOfBirth.ISO8601Format() : nil
                
                let updatedClient = Client(
                    id: clientId,
                    firstName: self.firstName,
                    lastName: self.lastName,
                    email: self.email,
                    phone: self.phone,
                    dateOfBirth: dateOfBirth,
                    locationId: self.locationId ?? "",
                    employeeId: employeeId
                )
                
                try await self.apiService
                    .updateClient(client: updatedClient)
                
                self.viewLifecycleService
                    .reload(for: .clientList)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Client updated successfully.",
                        action: {
                            self.navigationService?.pop()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while updating your client. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension ClientCreateEditViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientCreateEdit(clientId: self.clientId)))
    }
    
}

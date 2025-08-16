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
    
    @Published private(set) var business: Business?
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.firstName.isEmpty &&
            !self.lastName.isEmpty &&
            !self.phone.isEmpty &&
            !self.email.isEmpty
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
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
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
                            message: Constants.Error.fetchErrorMessage("client"),
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
    
    func save() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let newClient = Client(
                    id: UUID().uuidString,
                    firstName: self.firstName,
                    lastName: self.lastName,
                    email: self.email,
                    phone: self.phone,
                    birthDate: nil,
                    employee: .DUMMY_DATA()
                )
                
                try await self.apiService
                    .createClient(
                        client: newClient,
                        locationId: self.locationId ?? ""
                    )
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "User created successfully.",
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
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension ClientCreateEditViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientCreateEdit(clientId: self.clientId)))
    }
    
}

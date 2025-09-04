//
//  BusinessEmployeeInviteViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import Foundation

final class BusinessEmployeeInviteViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_EMPLOYEE_INVITE_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var selectedRole: Role? = .employee
    @Published var selectedLocations: [Location] = []
    
    private var isOwner: Bool {
        return self.activeDestinationService.isOwner
    }
    
    let locationRoles = Role.LocationRoles
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.name.isEmpty &&
            !self.email.isEmpty
        )
        
    }
    
    var eligibleLocations: [Location] = []
    
    private var businessId: String!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(businessId: String) -> Self {
        
        self.businessId = businessId
        return self
        
    }
    
    func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let business = try await self.apiService
                    .getBusiness(id: self.businessId)
                
                await MainActor.run { [weak self] in
                    
                    self?.business = business
                    self?.setEligableLocations()
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("business"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func updateSelectedLocations(_ locationNames: [String]) {
        
        let businessLocations = self.business?.locations ?? []
        
        self.selectedLocations = []
        locationNames.forEach { locationName in
            
            if let location = businessLocations.first(where: { $0.name == locationName }) {
                self.selectedLocations.append(location)
            }
            
        }
        
    }
    
    func updateSelectedRole(_ role: Role?) {
        self.selectedRole = role
    }
    
    func inviteEmployee() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let invite = EmployeeInvite(
                    id: UUID().uuidString,
                    name: self.name,
                    email: self.email,
                    businessName: self.business?.name ?? "",
                    locations: self.selectedLocations,
                    role: self.selectedRole
                )
                
                try await self.apiService.createEmployeeInvite(invite: invite)
                
                await presentSuccessAlert()
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "employee invite"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
    private func setEligableLocations() {
        
        let allLocations = self.business?.locations ?? []
        let locationId = self.activeDestinationService.activeDestination?.destinationId
        let currentLocationArray = allLocations.filter { $0.id == (locationId ?? "") }
        
        let isLocationContext = self.activeDestinationService.activeDestination?.isLocation ?? false
        
        if isLocationContext {
            
            self.eligibleLocations = currentLocationArray
            self.selectedLocations = currentLocationArray
            
        } else {
            
            self.eligibleLocations = allLocations
            
        }
                
    }
    
    @MainActor
    private func presentSuccessAlert() {
        
        alertService.showAlert(
            .init(.card(.invitationAlert(
                name: self.name,
                businessName: self.business?.name ?? "") { [weak self] in
                    self?.navigationService?.pop()
                }
            )))
        
    }
    
}

extension BusinessEmployeeInviteViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessEmployeeInvite(
            businessId: self.businessId
        )))
        
    }
    
}

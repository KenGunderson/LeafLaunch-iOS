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
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var selectedRole: Role? = .employee
    @Published var selectedLocations: [Location] = []
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.name.isEmpty &&
            !self.email.isEmpty
        )
        
    }
    
    private var businessId: String!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
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
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.errorMessage("business"),
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
                            message: Constants.Error.errorMessage(context: .create, "employee invite"),
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

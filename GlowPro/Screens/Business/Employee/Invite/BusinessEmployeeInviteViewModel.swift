//
//  BusinessEmployeeInviteViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import Foundation

final class BusinessEmployeeInviteViewModel: ViewModel {
    
    enum Context: Equatable {
        
        case newEmployee
        
        case updateEmployee(employee: Employee,
                            roleLocations: [Workspace.RoleLocation])
        
    }
    
    internal let loggerName: String = "BUSINESS_EMPLOYEE_INVITE_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
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
    private var context: Context!
    
    var isUpdatingEmployeeContext: Bool {
        return self.context != .newEmployee
    }
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(businessId: String,
               context: Context) -> Self {
        
        self.businessId = businessId
        self.context = context
        
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
        
        if shouldShowLimitAlert() {
            return
        }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let business = try await self.apiService
                    .getBusiness(id: self.businessId)
                
                await MainActor.run { [weak self] in
                    
                    self?.business = business
                    
                    if case let .updateEmployee(employee, roleLocations) = self?.context {
                        
                        self?.name = employee.name
                        self?.email = employee.email
                        self?.setEligibleLocations(roleLocations: roleLocations)
                        
                    } else {
                        self?.setEligibleLocations()
                    }
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("business"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
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
        
        if !email.isEmpty,
           !self.email.isValidEmail() {
            
            self.alertService
                .showAlert(Constants.INVALID_EMAIL_ALERT())
            
            return
            
        }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let invite = EmployeeInvite(
                    id: UUID().uuidString,
                    name: self.name,
                    email: self.email,
                    businessId: self.businessId,
                    businessName: self.business?.name ?? "",
                    locationIds: self.selectedLocations.map { $0.id },
                    role: self.selectedRole,
                    createdAt: Date().toISO()
                )
                
                try await self.apiService.createEmployeeInvite(invite: invite)
                self.viewLifecycleService.reload(for: .businessHome)
                
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
    
    private func setEligibleLocations(roleLocations: [Workspace.RoleLocation] = []) {
        
        let roleLocations = roleLocations.map({ $0.location })
        var allLocations = self.business?.locations ?? []
        
        allLocations = allLocations.filter({ !roleLocations.contains($0) })
        
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
                    
                    self?.navigationService?
                        .popWithDelay()
                    
                }
            )))
        
    }
    
    private func shouldShowLimitAlert() -> Bool {
        
        if let alert = self.activeDestinationService.showLimitAlertIfNeeded(
            type: .employee,
            subscribeAction: { [weak self] in
                self?.showPaywall()
            },
            dismissAction: { [weak self] in
                self?.navigationService?.popWithDelay()
            }
        ) {
            
            Task { @MainActor in
                
                self.alertService.showAlert(.init(
                    .card(.limitReachedAlert(limitReachedAlert: alert))
                ))
                
            }
            
            return true
            
        }
        
        return false
        
    }
    
    private func showPaywall() {
        
        Task { @MainActor in
            
            let paywallContext = self.activeDestinationService.getPaywallOverageContext()
            
            self.navigationService?.modal(fullScreenCover: .subscriptionPaywall(
                context: paywallContext,
                paywallItem: .GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION,
                completion: nil
            ))
            
            self.navigationService?.pop()
            
        }
        
    }
    
}

extension BusinessEmployeeInviteViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessEmployeeInvite(
            businessId: self.businessId
        )))
        
    }
    
}

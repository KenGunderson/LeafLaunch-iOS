//
//  ActiveEntityService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/25.
//

import Combine

final class ActiveDestinationService: ActiveDestinationServiceProtocol {    
    
    internal let loggerName: String = "ACTIVE_DESTINATION_SERVICE"
    internal let loggerEmoji: String = "🛩️"
    
    private let apiService: APIServiceProtocol!
    private var authService: AuthServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol!
    
    @Published private(set) var activeDestination: ActiveDestination?
    var activeDestinationPublisher: AnyPublisher<ActiveDestination?, Never> {
        return self.$activeDestination.eraseToAnyPublisher()
    }
    
    @Published private(set) var isOwner: Bool = false
    @Published internal var locationEmployee: LocationEmployee?
    
    internal var isTemporaryLocationEmployee: Bool = false
    
    var role: Role? {
        return self.locationEmployee?.role
    }
    
    var isManager: Bool {
        return self.locationEmployee?.role == .manager
    }
    
    var isOwnerOrManager: Bool {
        return self.isOwner || self.role == .manager
    }
    
    var isSubscribed: Bool {
        return self.business?.isSubscribed ?? false
    }
    
    var isMediaLimitReached: Bool {
        
        let business = self.business
        let allowsOverages = business?.businessSettings?.allowsOverages ?? false
        let isLimitReached = business?.stripeSubscriptionOverageUsage?.isLimitReached ?? false
        
        if allowsOverages {
            return false
        }
        
        return isLimitReached
        
    }
    
    var canAddAnotherLocation: Bool {
        
        let totalNumberOfLocations = self.business?.totalLocationCount ?? 0
        let allowedNumberOfLocations = self.business?.stripeSubscriptionProduct?.metadata?.totalNumberOfLocations ?? 1
        
        // Infinite
        if allowedNumberOfLocations == -1 {
            return true
        }
        
        return totalNumberOfLocations < allowedNumberOfLocations
        
    }
    
    var canAddAnotherEmployee: Bool {
        
        let totalNumberOfEmployees = (self.business?.totalEmployeeCount ?? 0 - 1) // Since the owner counts
        let allowedNumberOfEmployees = self.business?.stripeSubscriptionProduct?.metadata?.totalNumberOfEmployees ?? 2
        
        // Infinite
        if allowedNumberOfEmployees == -1 {
            return true
        }
        
        return totalNumberOfEmployees < allowedNumberOfEmployees
        
    }
    
    internal var business: Business?
    internal var businessId: String?
    
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setAuthService(_ authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func setActiveDestination(_ destination: ActiveDestination) {
        
        self.activeDestination = destination
        loadData()
        self.log(message: "Set active destination: \(destination.prettyLog)")
        
    }
    
    func removeActiveDestination() {
        
        self.activeDestination = nil
        self.business = nil
        self.businessId = nil
        
        self.log(message: "Set active destination to NIL")
        
    }
    
    func setTemporaryLocationEmployee(_ locationId: String) {
        
        guard let userId = self.business?.owner.id else { return }
        
        Task {
            
            let employeeId = try await self.apiService.getEmployeeByUserIdForLocation(
                userId: userId,
                locationId: locationId
            )
            
            let locationEmployee = try await self.apiService.getLocationEmployee(
                employeeId: employeeId,
                locationId: locationId
            )
            
            await MainActor.run {
                
                self.isTemporaryLocationEmployee = true
                self.locationEmployee = locationEmployee
                self.log(message: "Set Temporary Location Employee: \(locationEmployee.id)")
                
            }
            
        }
        
    }
    
    func removeTemporaryLocationEmployee() {
        
        guard self.isTemporaryLocationEmployee else { return }
        
        self.isTemporaryLocationEmployee = false
        self.locationEmployee = nil
        
        self.log(message: "Removed Temporary Location Employee")
        
    }
    
    func logout() {
        
        self.activeDestination = nil
        self.log(message: "Set active destination to NIL")
        
    }
    
    func refresh() {
        loadData()
    }
    
    func getPaywallOverageContext() -> SubscriptionPaywallViewModel.Context {
        
        var paywallContext: SubscriptionPaywallViewModel.Context = .create
        
        if let subscription = self.business?.stripeSubscription,
           let subscriptionProduct = self.business?.stripeSubscriptionProduct {
            
            let selectedInterval = SubscriptionPaywallViewModel.Interval.createFromStripeName(subscription.stripeInterval)
            
            paywallContext = .update(
                stripeSubscriptionId: subscription.stripeSubscriptionId,
                selectedProduct: subscriptionProduct,
                selectedInterval: selectedInterval
            )
            
        }
        
        return paywallContext
        
    }
    
    func showLimitAlertIfNeeded(type: AppCardConfig.LimitType,
                                subscribeAction: @escaping () -> Void,
                                dismissAction: @escaping () -> Void) -> AppCardConfig.LimitReachhedAlert? {
        
        guard let business else { return nil }
                
        var isOverLimit: Bool {
            
            switch type {
            case .employee: return !self.canAddAnotherEmployee
            case .location: return !self.canAddAnotherLocation
            case .media: return self.isMediaLimitReached
            }
            
        }
        
        if !isOverLimit {
            return nil
        }
        
        return .init(
            type: type,
            businessName: business.name,
            isSubscribed: business.isSubscribed,
            subscribeAction: subscribeAction,
            dismissAction: dismissAction)
        
    }
    
    private func loadData() {
        
        guard let activeDestination else {
        
            self.business = nil
            self.businessId = nil
            
            self.log(message: "Set active destination to NIL")
            
            return
            
        }
        
        guard let currentUserId = self.authService?.currentUser?.id else { return }
        
        var business: Business?
        var locationEmployee: LocationEmployee?
        
        switch activeDestination {
        case .business(_, let fetchedBusiness):
            
            business = fetchedBusiness
            
        case .location(_, _, let fetchedLocationEmployee, let fetchedBusiness):
            
            locationEmployee = fetchedLocationEmployee
            business = fetchedBusiness
        }
        
        self.isTemporaryLocationEmployee = false
        
        self.isOwner = (business?.owner.id == currentUserId)
        self.locationEmployee = locationEmployee
        
        if let business {
            
            self.log(message: "Loaded Business: \(business.id)")
            self.business = business
            self.businessId = business.id
            
        }
        
        if let locationEmployee {
            self.log(message: "Loaded Employee: \(locationEmployee.id)")
        }
        
    }

}

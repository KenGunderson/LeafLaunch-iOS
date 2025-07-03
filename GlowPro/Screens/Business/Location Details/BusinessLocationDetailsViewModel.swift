//
//  BusinessLocationDetailsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessLocationDetailsViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_LOCATION_DETAILS_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    @Published private(set) var location: Location?
    
    private var businessId: String!
    private var locationId: String!

    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    init(authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
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
    func setup(businessId: String,
               locationId: String) -> Self {
        
        self.businessId = businessId
        self.locationId = locationId
        
        return self
        
    }
    
    func navigate(to route: Route) {
        
        self.tabBarNavigationService?
            .currentNavigationService()
            .push(route)
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func loadData() {
        
        self.business = .DUMMY_DATA()
        self.location = .DUMMY_DATA()
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessLocationDetailsViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessLocationDetails(
            businessId: self.businessId,
            locationId: self.locationId
        )))
        
    }
    
}

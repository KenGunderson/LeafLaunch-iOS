//
//  BusinessEditDetailsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessEditDetailsViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_EDIT_DETAILS_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var street: String = ""
    @Published var street2: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zip: String = ""
    
    private var businessId: String!

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
    func setup(businessId: String) -> Self {
        
        self.businessId = businessId
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
        
        guard let business else { return }
        self.name = business.name
        self.email = business.email ?? ""
        self.phone = business.phoneNumber ?? ""
        self.street = business.address?.street ?? ""
        self.street2 = business.address?.street2 ?? ""
        self.city = business.address?.city ?? ""
        self.state = business.address?.state ?? ""
        self.zip = business.address?.zip ?? ""
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessEditDetailsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessEditDetails(businessId: self.businessId)))
    }
    
}

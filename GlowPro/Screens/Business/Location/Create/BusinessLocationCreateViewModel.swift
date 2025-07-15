//
//  BusinessEmployeeCreateViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import Foundation

final class BusinessLocationCreateViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_LOCATION_CREATE_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
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
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.name.isEmpty &&
            !self.phone.isEmpty &&
            !self.email.isEmpty &&
            !self.street.isEmpty &&
            !self.city.isEmpty &&
            !self.state.isEmpty &&
            !self.zip.isEmpty
        )
        
    }
    
    private var businessId: String!

    private var tabBarNavigationService: TabBarNavigationService?
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
        
        self.tabBarNavigationService?
            .currentNavigationService()
            .push(route)
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
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
                            message: "Something went wrong while fetching your business. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func save() {
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessLocationCreateViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessLocationCreate(
            businessId: self.businessId
        )))
        
    }
    
}

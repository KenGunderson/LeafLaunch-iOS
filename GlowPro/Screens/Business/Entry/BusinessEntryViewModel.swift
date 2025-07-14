//
//  BusinessEntryViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/25.
//

import Foundation

final class BusinessEntryViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_ENTRY_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var businesses: [Business] = []
    @Published private(set) var locations: [Location] = []

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
    
    // TODO: - DO NOT NAVIGATE. SET THE SERVICES LOCATION PROPERLY
    func selectBusiness(_ business: Business) {
        navigate(to: .business(.businessDetails(businessId: business.id)))
    }
    
    func selectLocation(_ location: Location) {
        
        navigate(to: .business(.businessLocationDetails(
            businessId: location.id,
            locationId: location.businessId
        )))

    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let businesses = try await self.apiService.getBusinesses()
                let locations = try await self.apiService.getLocations()
                
                await MainActor.run { [weak self] in

                    self?.businesses = businesses
                    self?.locations = locations
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while fetching your data. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    private func navigate(to route: Route) {
        
        self.tabBarNavigationService?
            .currentNavigationService()
            .push(route)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessEntryViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessEntry))
    }
    
}

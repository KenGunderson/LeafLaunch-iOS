//
//  BusinessLocationListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessLocationListViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_LOCATION_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    @Published private(set) var locations: [Location] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private(set) var businessId: String!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isOwner: Bool {
        return self.activeDestinationService.isOwner
    }
    
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
    
    func selectLocation(_ location: Location) {
        
        navigate(to: .business(.businessLocationDetails(
            businessId: self.businessId,
            locationId: location.id)
        ))
        
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
                    self?.locations = business.locations
                    self?.shouldShowEmptyState = business.locations.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("locations"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Locations Found",
            message: "Start building your business by adding your first location",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Location",
            action: {
                
                self.navigationService?.push(.business(.businessLocationCreateEdit(
                    businessId: self.businessId,
                    locationId: nil
                )))
                
            }
        )
        
    }
    
    private func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessLocationListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessLocationList(businessId: self.businessId)))
    }
    
}

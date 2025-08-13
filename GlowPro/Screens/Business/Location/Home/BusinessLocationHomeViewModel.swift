//
//  BusinessLocationHomeViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import Foundation

final class BusinessLocationHomeViewModel: ViewModel {
    
    internal let loggerName: String = "LOCATION_HOME_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var currentUser: GPUser?
    @Published private(set) var location: Location?
    
    private var locationId: String!
    
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        bindSubsribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(locationId: String) -> Self {
        
        self.locationId = locationId
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func bindSubsribers() {
        
        self.cancelBag = CancelBag()
        
        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &self.cancelBag)
        
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let location = try await self.apiService.getLocation(id: self.locationId)
                
                await MainActor.run { [weak self] in
                    self?.location = location
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while fetching your location. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
}

extension BusinessLocationHomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessLocationHome(locationId: self.locationId)))
    }
    
}

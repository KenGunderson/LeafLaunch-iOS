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
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var location: Location?
    
    private(set) var businessId: String!
    private var locationId: String!

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
    func setup(businessId: String,
               locationId: String) -> Self {
        
        self.businessId = businessId
        self.locationId = locationId
        
        return self
        
    }
    
    func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    func setActiveDestination(_ activeDestination: ActiveDestination) {
        
        let currentDestinationId = self.activeDestinationService.activeDestination?.destinationId
        let nextDestinationId = activeDestination.destinationId
        
        guard currentDestinationId != nextDestinationId else { return }
        
        self.activeDestinationService
            .setActiveDestination(activeDestination)
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let location = try await self.apiService
                    .getLocation(id: self.locationId)
                
                await MainActor.run { [weak self] in
                    self?.location = location
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("location"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func presentDeleteLocationAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Location"),
                message: Constants.Message.deleteConfirmationMessage("location"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteLocation()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteLocation() {
        
        Task {
            
            do {
                
                try await self.apiService
                    .deleteLocation(id: self.locationId)
                
                await MainActor.run { [weak self] in
                    self?.navigationService?.pop()
                }
                
            }
            catch {
                
                self.alertService
                    .showAlert(.init(.appAlert(.error(
                        message: Constants.Message.errorMessage(context: .delete, "location"),
                        action: {})
                    )))
                
            }
            
        }
        
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

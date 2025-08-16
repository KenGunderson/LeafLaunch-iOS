//
//  BusinessEmployeeJoinViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/25.
//

import Foundation

final class BusinessEmployeeJoinViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_EMPLOYEE_JOIN_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var businesses: [Business] = []
    @Published var codeText: String = ""
    
    var isSaveButtonEnabled: Bool {
        return true
    }

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.activeDestinationService = activeDestinationService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
//                let businesses = try await self.apiService.getBusinesses()
//                
//                await MainActor.run { [weak self] in
//                    self?.businesses = businesses
//                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.fetchErrorMessage("data"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    private func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessEmployeeJoinViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessEmployeeJoin))
    }
    
}

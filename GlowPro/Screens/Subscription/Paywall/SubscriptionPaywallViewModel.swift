//
//  SubscriptionPaywallViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import Foundation

final class SubscriptionPaywallViewModel: ViewModel {
    
    internal let loggerName: String = "PAYWALL_VIEW_MODEL"
    internal let loggerEmoji: String = "👮🏻‍♂️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    @Published private(set) var shouldDismiss: Bool = false
    
    @Published var paywallItem: SubscriptionPaywallItem!
        
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
    
    @discardableResult
    func setup(paywallItem: SubscriptionPaywallItem) -> Self {
        
        self.paywallItem = paywallItem
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
    }
    
    func subscribe() {
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension SubscriptionPaywallViewModel {
    
    func track() {
        self.analyticsService.track(screen: .subscription(.paywall))
    }
    
}

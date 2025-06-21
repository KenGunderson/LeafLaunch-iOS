//
//  ClientDetailsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import Foundation

final class ClientDetailsViewModel: ViewModel {
    
    internal let loggerName: String = "CLIENT_DETAILS_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var client: Client?
    @Published var selectedActivitiesFilter: String?
    
    private var clientId: String!

    private var navigationService: NavigationService?
    private var dismissAction: (() -> ())?
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
    func setup(clientId: String) -> Self {
        
        self.clientId = clientId
        return self
        
    }
    
    func navigate(to route: Route) {
        self.navigationService?.push(route)
    }
    
    func setup(navigationService: NavigationService,
               dismissAction: @escaping (() -> ())) {
        
        self.navigationService = navigationService
        self.dismissAction = dismissAction
        
    }
    
    func loadData() {
        self.client = .DUMMY_DATA()
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension ClientDetailsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientDetails(clientId: self.clientId)))
    }
    
}

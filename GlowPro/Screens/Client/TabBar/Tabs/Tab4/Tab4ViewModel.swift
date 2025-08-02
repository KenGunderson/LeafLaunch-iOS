//
//  TabBar4ViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

final class Tab4ViewModel: ViewModel {
    
    internal let loggerName: String = "TAB_4_VIEW_MODEL"
    internal let loggerEmoji: String = "🔹"
    
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    init(authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
}

extension Tab4ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .tab(.tab4))
    }
    
}

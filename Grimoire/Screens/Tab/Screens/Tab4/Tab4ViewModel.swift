//
//  TabBar4ViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

final class Tab4ViewModel: ViewModel {
    
    internal let loggerName: String = "TAB_4_VIEW_MODEL"
    internal let loggerEmoji: String = "🔹"
    
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    init(authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol) {
        
        self.authService = authService
        self.analyticsService = analyticsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func loadData(showHud: Bool = false) {
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
}

extension Tab4ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main(.tabIntent(tab: .tab4)))
    }
    
}

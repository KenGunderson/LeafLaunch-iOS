//
//  TabBar3ViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class Tab3ViewModel: ViewModel {
    
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private let logger: GPLogger = .viewModel(.tab3)
    private var cancelBag: CancelBag!
    
    init(authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol) {
        
        self.authService = authService
        self.analyticsService = analyticsService
        
        self.logger.logInit()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
}

extension Tab3ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .tab(.tab3))
    }
    
}

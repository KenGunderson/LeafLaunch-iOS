//
//  TabBar2ViewModel.swift
//  Rune2
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class Tab2ViewModel: ViewModel {
    
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private let logger: RuneLogger = .viewModel(.tab2)
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

extension Tab2ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .tab(.tab2))
    }
    
}

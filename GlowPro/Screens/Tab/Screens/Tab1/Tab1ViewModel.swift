//
//  TabBar1ViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class Tab1ViewModel: ViewModel {
    
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private let logger: GPLogger = .viewModel(.tab1)
    private var cancelBag: CancelBag!
    
    init(authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logger.logInit()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func setRandomTheme() {
        
        self.userDefaultsService
            .set(theme: AvailableTheme.allCases.randomElement()!)
        
    }
    
}

extension Tab1ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .tab(.tab1))
    }
    
}

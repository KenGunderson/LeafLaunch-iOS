//
//  DevDeeplinksViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI
import Combine

final class DevDeeplinksViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    @MainActor
    func handleDeeplink(url: URL) {
        
        globalTabBarNavigationService
            .currentNavigationService()
            .dismissFullScreenCover()
        
        UIApplication.shared.open(url)
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension DevDeeplinksViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.deeplinks))
    }
    
}

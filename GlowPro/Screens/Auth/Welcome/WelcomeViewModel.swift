//
//  WelcomeViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 5/16/25.
//


import SwiftUI
import Combine

final class WelcomeViewModel: ViewModel {
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private let logger = GPLogger.viewModel(.welcome)
            
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        self.logger.logInit()
        
        bindSubscribers()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func navigateToLogin() {
        
        self.navigationService?
            .push(.auth(.login))
        
    }
    
    func navigateToSignUp() {
        
        self.navigationService?
            .push(.auth(.signup))
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension WelcomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .onboarding(.start))
    }
    
}

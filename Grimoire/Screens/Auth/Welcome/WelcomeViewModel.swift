//
//  WelcomeViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 5/16/25.
//


import SwiftUI
import Combine

final class WelcomeViewModel: ViewModel {
    
    internal let loggerName: String = "WELCOME_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isNotProduction: Bool {
        self.environmentService.environment != .production
    }
            
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        self.logInit()
        
        bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
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

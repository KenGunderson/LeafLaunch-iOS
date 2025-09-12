//
//  AboutUsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI
import Combine

final class AboutUsViewModel: ViewModel {
    
    internal let loggerName: String = "ABOUT_US_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    
    private var cancelBag: CancelBag!
        
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
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
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func aboutUsMessage() -> String {
        
        return """
        GlowPro is the all-in-one mobile platform built for beauty and med-spa professionals who want more than just a booking tool — they want a business partner. Designed with care from the ground up, GlowPro combines seamless client management, beautiful media galleries, and subscription-based tools to help businesses grow, engage, and retain their clients. Every feature, from onboarding to analytics, is designed to feel effortless and polished, empowering professionals to focus on what matters most: creating transformational experiences for their clients.
        
        GlowPro isn’t just software — it’s an ecosystem. With secure photo workflows, customizable design themes, and a robust backend built for scalability, GlowPro gives businesses confidence that their data, their brand, and their clients are always supported. Whether you’re running one location or many, GlowPro adapts with you — offering everything from employee management to media favorites, community insights, and even usage-based subscription tiers. We’re here to make sure your business runs beautifully.    
        """
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension AboutUsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.faq))
    }
    
}

//
//  TabBar1ViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class Tab1ViewModel: ViewModel {
    
    internal let loggerName: String = "TAB_1_VIEW_MODEL"
    internal let loggerEmoji: String = "🔹"
    
    private let alertService: AlertServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    init(alertService: AlertServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.alertService = alertService
        self.authService = authService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func loadData(showHud: Bool = false) {
        
    }
    
    func logout() {
        
        Task {
            try? await self.authService.logout()
        }
        
    }
    
    func setRandomTheme() {
        
        self.userDefaultsService
            .set(theme: AvailableTheme.allCases.randomElement()!)
        
    }
    
    func presentAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.success(message: "Test", action: {
                
            }))))
        
    }
    
}

extension Tab1ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main(.tabIntent(tab: .tab1)))
    }
    
}

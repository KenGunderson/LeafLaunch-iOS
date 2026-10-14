//
//  TabBar2ViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class Tab2ViewModel: ViewModel {
    
    internal let loggerName: String = "TAB_2_VIEW_MODEL"
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

    func toggleTheme() {

        self.userDefaultsService
            .set(theme: self.userDefaultsService.theme.toggled)

    }
    
    func presentAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.success(message: "Test", action: {
                
            }))))
        
    }
    
}

extension Tab2ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main(.tabIntent(tab: .tab2)))
    }
    
}

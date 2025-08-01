//
//  SettingsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import Foundation

final class SettingsViewModel: ViewModel {
    
    internal let loggerName: String = "SETTINGS_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func selectSetting(_ setting: Route.Setting) {
        
        switch setting {
        case .logout:
            
            Task { [weak self] in
                
                guard let self else { return }          
                try await self.authService.logout()
                
            }
            
        default: self.navigationService?.push(.setting(setting))
        }
        
    }
    
    func setup(navigationService: NavigationService){
        self.navigationService = navigationService
    }
    
    func loadData() {

    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension SettingsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.settings))
    }
    
}

//
//  SettingsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import Foundation
import UIKit

final class SettingsViewModel: ViewModel {
    
    internal let loggerName: String = "SETTINGS_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published var shouldDismiss: Bool = false
    
    @MainActor
    var appVersion: String {
        return UIApplication.version
    }
    
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
            
            presentLogoutAlert()
            
        default:
            
            self.navigationService?.push(.setting(setting))
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
    
    private func logout() {
        
        Task { [weak self] in
            
            guard let self else { return }
            
            try await Task.sleep(for: .seconds(0.3))
            
            await MainActor.run {
                self.shouldDismiss = true
            }
            
            try await Task.sleep(for: .seconds(0.3))
            try await self.authService.logout()
            
        }
        
    }
    
    private func presentLogoutAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Logout?",
                message: "Are you sure you want to logout?",
                primaryButtonTitle: "Okay",
                primaryButtonAction: { [weak self] in
                    self?.logout()
                },
                primaryButtonBackgroundColor: Style.shared.accent,
                primaryButtonTextColor: Style.shared.textColor(.button),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.error),
                secondaryButtonTextColor: Style.shared.textColor(.titleInverted)
            ))))
        
    }
    
}

extension SettingsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.settings))
    }
    
}

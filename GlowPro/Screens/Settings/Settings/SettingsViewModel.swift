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
    private let environmentService: EnvironmentServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published var shouldDismiss: Bool = false
    @Published var shouldShowRateAppAlert: Bool = false
    @Published var shouldShowMailComposer: Bool = false
    
    @MainActor
    var appVersion: String {
        
        let env = self.environmentService.environment?.description ?? ""
        return "\(env) - \(UIApplication.version)"
        
    }
    
    var emailData: EmailData {
        
        return .init(
            subject: "Customer Support",
            recipients: [Constants.Legal.supportEmail],
            body: "",
            isHTML: false,
            attachments: [])
        
    }
    
    init(authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         impersonateService: ImpersonateServiceProtocol) {
        
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.environmentService = environmentService
        self.userDefaultsService = userDefaultsService
        self.impersonateService = impersonateService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func selectSetting(_ setting: Route.Setting) {
        
        switch setting {
        case .logout:
            
            presentLogoutAlert()
            
        case .contactSupport:
            
            self.shouldShowMailComposer = true
            
        case .writeAReview:
            
            reviewApp()
            
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
    
    private func reviewApp() {
        
        self.shouldShowRateAppAlert = true
        self.userDefaultsService.set(didRateMyAppAlertShow: true)
        
    }
    
    private func logout() {
        
        Task { [weak self] in
            
            guard let self else { return }
            
            try await Task.sleep(for: .seconds(0.3))
            
            self.impersonateService
                .logout()
            
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
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.logout()
                },
                primaryButtonBackgroundColor: Style.shared.accent,
                primaryButtonTextColor: Style.shared.textColor(.button),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
}

extension SettingsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.settings))
    }
    
}

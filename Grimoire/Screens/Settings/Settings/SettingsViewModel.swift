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
    private let apiService: APIServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol

    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var shouldDismiss: Bool = false
    
    @Published private(set)var isLoading: Bool = true
    @Published private(set) var isFirstLoad: Bool = true
    
    @Published var shouldShowRateAppAlert: Bool = false
    @Published var shouldShowMailComposer: Bool = false
    
    @MainActor
    var appVersion: String {
        
        let env = self.environmentService.environment?.description ?? ""
        return "\(env) - \(UIApplication.version)"
        
    }
    
    var emailData: EmailComposerData {
        
        return .init(
            subject: "Customer Support",
            recipients: [Constants.Legal.supportEmail],
            body: "",
            isHTML: false,
            attachments: [])
        
    }
    
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         impersonateService: ImpersonateServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.environmentService = environmentService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        self.impersonateService = impersonateService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @MainActor
    func selectSetting(_ setting: Route.SettingRoute) {
        
        switch setting {
        case .logout:
            
            presentLogoutAlert()
            
        case .updatePermissions:
            
            self.alertService
                .showAlert(.init(.appAlert(.success(message: "Clicked the correct button", action: {
                    print("Test")
                }))))
            
            ToastManager
                .shared
                .present(toastItem: .init(title: "Some Toasy"))
            
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }
            
        case .contactSupport:
            
            self.shouldShowMailComposer = true
            
        case .rateApp:
            
            reviewApp()
            
        default:
            
            self.navigationService?.push(.settings(setting))
        }
        
    }
    
    func setup(navigationService: NavigationService){
        self.navigationService = navigationService
    }
    
    func loadData(showHud: Bool = true) {
        
        self.isLoading = false
        self.isFirstLoad = false
        
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

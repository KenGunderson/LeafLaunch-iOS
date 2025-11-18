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
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var workspaces: [Workspace] = []
    @Published private(set) var isSubscribed: Bool = false
    
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
    
    var shouldShowSecuritySetting: Bool {
        return self.workspaces.filter({ $0.isOwner }).first != nil
    }
    
    var shouldShowSubscriptionSetting: Bool {
        return self.activeDestinationService.businessId != nil
    }
    
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         impersonateService: ImpersonateServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
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
            
        case .subscribe:
            
            self.navigationService?
                .modal(fullScreenCover: .subscriptionPaywall(
                    context: .create,
                    paywallItem: .GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION,
                    completion: { [weak self] in
                                                
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                            self?.shouldDismiss = true
                        }
                        
                    }
                ))
            
        case .manageSubscription:
            
            let businessId = self.activeDestinationService.businessId ?? ""
            
            self.navigationService?
                .modal(fullScreenCover: .subscriptionManage(businessId: businessId))
            
        case .updatePermissions:
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            
        case .contactSupport:
            
            self.shouldShowMailComposer = true
            
        case .rateApp:
            
            reviewApp()
            
        default:
            
            self.navigationService?.push(.setting(setting))
        }
        
    }
    
    func setup(navigationService: NavigationService){
        self.navigationService = navigationService
    }
    
    func loadData(showHud: Bool = true) {
        
        self.isLoading = (self.isFirstLoad)
        
        if self.isFirstLoad {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }

        Task {
            
            do {
                
                let workspaces = try await self.apiService
                    .getWorkspaces(userId: self.authService.currentUser?.id ?? "")
                
                await MainActor.run { [weak self] in
                    
                    self?.isSubscribed = self?.activeDestinationService.business?.stripeSubscriptionProduct != nil
                    self?.workspaces = workspaces
                    self?.isLoading = false
                    
                }
                
            }
            catch {
                
                await MainActor.run { [weak self] in
                    self?.isLoading = false
                }
                
            }
            
            if self.isFirstLoad {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
            await MainActor.run { [weak self] in
                
                self?.isLoading = false
                self?.isFirstLoad = false
                
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .settings)
            .receiveOnMain()
            .sink { [weak self] in
                
                self?.loadData(showHud: false)
                
            }
            .store(in: &self.cancelBag)
        
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

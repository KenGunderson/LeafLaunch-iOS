//
//  RootViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import SwiftUI
import FactoryKit

final class RootViewModel: ViewModel {
    
    internal let loggerName: String = "ROOT_VIEW_MODEL"
    internal let loggerEmoji: String = "🪾"
    
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol
    private let pushNotificationService: PushNotificationServiceProtocol
    private(set) var userDefaultsService: UserDefaultsServiceProtocol
    private let deeplinkService: DeeplinkServiceProtocol
    private let startupService: RootStartupServiceProtocol
    
    @LazyInjected(\.mainViewModel) private(set) var mainViewModel: MainViewModel
    
    @Published private(set) var launchState: LaunchScreenService.State = .loading
    @Published private(set) var isImpersonatingUser: Bool = false
    @Published var shouldPresentDevSettings: Bool = false
    
    private(set) weak var navigationService: NavigationService?
    
    var impersonatingUserEmail: String {
        return self.impersonateService.impersonatedUser?.email ?? ""
    }
    
    var observableAlertServiceWrapper: ObservableAlertServiceWrapper!
    
    init(analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         authService: AuthServiceProtocol,
         impersonateService: ImpersonateServiceProtocol,
         pushNotificationService: PushNotificationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         deeplinkService: DeeplinkServiceProtocol,
         startupService: RootStartupServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.authService = authService
        self.impersonateService = impersonateService
        self.pushNotificationService = pushNotificationService
        self.userDefaultsService = userDefaultsService
        self.deeplinkService = deeplinkService
        self.startupService = startupService
        self.observableAlertServiceWrapper = ObservableAlertServiceWrapper(alertService: alertService)
        
        self.logInit()
        bindStartupCoordinator()
        
        Task {
            
            await MainActor.run {
                UITabBar.appearance().isHidden = true
            }
            
        }
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    // MARK: - PUBLIC
    
    @discardableResult
    func setup(appDelegate: AppDelegate) -> Self {
        
        self.startupService
            .setup(appDelegate: appDelegate)
        
        return self
        
    }
    
    func setDeeplink(url: URL) {
        
        self.deeplinkService
            .handle(url: url)
        
    }
    
    func setLaunchState(_ state: LaunchScreenService.State) {
        
        self.startupService
            .setLaunchState(state)
        
    }
    
    func markSplashAnimationCompleted() {
        
        self.startupService
            .markSplashAnimationCompleted()
        
    }
    
    func trackLauchScreen() {
        
        self.analyticsService
            .track(screen: .launch)
        
    }
    
    func revertImpersonatingUser() {
        
        Task { @MainActor [weak self] in
            try await self?.impersonateService.revert()
        }
        
    }
    
    func setNavigationService(_ tabBarNavigationService: TabBarNavigationService) {
        
        self.deeplinkService
            .setup(
                mainViewModel: self.mainViewModel,
                tabBarNavigationService: tabBarNavigationService
            )
        
        self.pushNotificationService
            .setup(tabBarNavigationService: tabBarNavigationService)
        
    }
    
    func presentDevSettings() {
        
        // TODO: - CHECK ENV FOR NON-PROD
        
        if self.authService.currentUser == nil {
            shouldPresentDevSettings = true
        }
        else {
            
            self.mainViewModel
                .tabBarNavigationService?
                .tab1NavigationService
                .modal(fullScreenCover: .devSettings)
            
        }
        
    }
    
    func presentHealthCheckAlert() {
        
        self.alertService
            .showAlert(.init(.enviornmentAlert(.init(config: Constants.HEALTH_CHECK_ENV_ALERT {
                // TODO: - RETRY
            }))))
        
    }
    
    func presentNoNetworkAlert() {
        
        self.alertService
            .showAlert(.init(.enviornmentAlert(.init(config: Constants.NO_NETWORK_ENV_ALERT {
                // TODO: - RETRY
            }))))
        
    }
    
    func presentForceUpdateAlert() {
        
        self.alertService
            .showAlert(.init(.enviornmentAlert(.init(config: Constants.FORCE_UPDATE_ENV_ALERT {
                // TODO: - RETRY
            }))))
        
    }
    
    // MARK: - PRIVATE
    
    private func bindStartupCoordinator() {
        
        self.startupService.start(
            onLaunchStateChanged: { [weak self] state in
                self?.launchState = state
            },
            onImpersonationStateChanged: { [weak self] isImpersonating in
                self?.isImpersonatingUser = isImpersonating
            },
            onAuthError: { [weak self] error in
                
                self?.logError(message: error.getMessageForError())
                self?.showAuthError(error)
                
            },
            onNoNetwork: { [weak self] in
                self?.presentNoNetworkAlert()
            },
            onHealthCheckResult: { [weak self] requiresForceUpdate in
                
                guard let self else { return }
                
                if requiresForceUpdate {
                    self.presentForceUpdateAlert()
                    return
                }
                
                self.presentHealthCheckAlert()
                
            }
        )
        
    }
    
    private func showAuthError(_ error: Error) {
        
        self.alertService.showAlert(.init(
            .appAlert(
                .error(message: error.getMessageForError(),
                       action: { [weak self] in
                           
                           self?.impersonateService.logout()
                           
                           Task { [weak self] in
                               try await self?.authService.logout()
                           }
                           
                       }))
        ))
        
    }
    
}

extension RootViewModel {
    
    func track() {
        self.analyticsService.track(screen: .root)
    }
    
}

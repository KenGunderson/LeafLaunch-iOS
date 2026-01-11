//
//  RootViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import SwiftUI

final class RootViewModel: ViewModel {
    
    internal let loggerName: String = "ROOT_VIEW_MODEL"
    internal let loggerEmoji: String = "🪾"
    
    private(set) var alertService: AlertServiceProtocol
    private let launchService: LaunchScreenServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let connectivityService: ConnectivityServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let pushNotificationService: PushNotificationServiceProtocol
    private(set) var userDefaultsService: UserDefaultsServiceProtocol
    private let deeplinkService: DeeplinkServiceProtocol
    
    private(set) var mainViewModel = globalResolver.resolve(MainViewModel.self)!
    
    @Published private(set) var launchState: LaunchScreenService.State = .loading
    @Published private(set) var shouldShowAuthError: Bool = false
    @Published private(set) var isImpersonatingUser: Bool = false
    @Published var shouldPresentDevSettings: Bool = false
    
    private(set) weak var navigationService: NavigationService?
    
    var impersonatingUserEmail: String {
        return self.impersonateService.impersonatedUser?.email ?? ""
    }
    
    var observableAlertServiceWrapper: ObservableAlertServiceWrapper!
    
    init(launchService: LaunchScreenServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         alertService: AlertServiceProtocol,
         apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         impersonateService: ImpersonateServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         connectivityService: ConnectivityServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         pushNotificationService: PushNotificationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         deeplinkService: DeeplinkServiceProtocol) {
        
        self.environmentService = environmentService
        self.launchService = launchService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.apiService = apiService
        self.authService = authService
        self.impersonateService = impersonateService
        self.firebaseService = firebaseService
        self.appDelegateService = appDelegateService
        self.connectivityService = connectivityService
        self.viewLifecycleService = viewLifecycleService
        self.pushNotificationService = pushNotificationService
        self.userDefaultsService = userDefaultsService
        self.deeplinkService = deeplinkService
        self.observableAlertServiceWrapper = ObservableAlertServiceWrapper(alertService: alertService)
        
        self.logInit()
        bindSubscribers()
        
        Task {
            
            await MainActor.run {
                UITabBar.appearance().isHidden = true
            }
                        
        }
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    private var cancelBag: CancelBag!
    
    // MARK: - PUBLIC
    
    @discardableResult
    func setup(appDelegate: AppDelegate) -> Self {
                
        self.appDelegateService
            .setup(appDelegate: appDelegate)
        
        return self
        
    }
    
    func setDeeplink(url: URL) {
        
        self.deeplinkService
            .handle(url: url)
        
    }
    
    func setLaunchState(_ state: LaunchScreenService.State) {
        
        self.launchService
            .setState(state)
        
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
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] environment in
                
                self?.getHealthCheck()
                
            }
            .store(in: &self.cancelBag)
        
        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                
                guard user != nil else { return }
                guard let deviceToken = self?.appDelegateService.deviceToken else { return }
                guard !(self?.impersonateService.isImpersonating ?? false) else { return }
                
                self?.registerDeviceToken(deviceToken)
                
            }
            .store(in: &self.cancelBag)
        
        self.authService
            .onError
            .receiveOnMain()
            .sink { [weak self] error in
                
                guard let strongSelf = self else { return }
                guard let error else { return }
                
                self?.logError(message: error.getMessageForError())
                strongSelf.showAuthError(error)
                
            }
            .store(in: &self.cancelBag)

        self.appDelegateService
            .deviceTokenPublisher
            .receiveOnMain()
            .sink { [weak self] token in
                
                guard let token else { return }
                self?.registerDeviceToken(token)
                
            }
            .store(in: &self.cancelBag)
        
        self.launchService
            .onLaunchStateChanged
            .receiveOnMain()
            .sink { [weak self] state in
                self?.launchState = state
            }
            .store(in: &self.cancelBag)
        
        self.connectivityService
            .onHasNetworkConnection
            .receiveOnMain()
            .sink { [weak self] hasNetworkConnection in
                
                guard !hasNetworkConnection else { return }
                self?.presentNoNetworkAlert()
                
            }
            .store(in: &self.cancelBag)
        
        self.viewLifecycleService
            .onWillEnterForeground
            .dropFirst(2)
            .receiveOnMain()
            .sink { [weak self] _ in
                
                guard let strongSelf = self else { return }
                
                Task {
                    
                    try await strongSelf
                        .authService.fetchUserInfoWithToken()
                    
                }
                
            }
            .store(in: &self.cancelBag)
        
        self.impersonateService
            .impersonatedUserPublisher
            .receiveOnMain()
            .sink { impersonatingUser in
                self.isImpersonatingUser = (impersonatingUser != nil)
            }
            .store(in: &self.cancelBag)

    }
    
    private func registerDeviceToken(_ token: String) {
        
        guard let user = self.authService.currentUser,
              self.firebaseService.user != nil else { return }
                
        Task { @MainActor in
            
            try await self.apiService.registerDevice(
                token: token,
                userId: user.id
            )
            
        }
        
    }
    
    private func getHealthCheck() {
        
        guard self.environmentService.environment != .development else {
            return
        }
        
        Task { @MainActor in
            
            do {
                try await self.apiService.getHealth()
            }
            catch {
                
                if let apiError = error as? APIError,
                   case let .serverError(statusCode, _) = apiError,
                   statusCode == 426 {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.presentForceUpdateAlert()
                    }
                    
                    return
                    
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.presentHealthCheckAlert()
                }
                
            }
            
        }
        
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

//
//  RootStartupCoordinator.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 2/16/26.
//

import SwiftUI

final class RootStartupService: RootStartupServiceProtocol, Loggable {
    
    internal let loggerName: String = "ROOT_STARTUP_SERVICE"
    internal let loggerEmoji: String = "🚀"
    
    private let launchService: LaunchScreenServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let connectivityService: ConnectivityServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var cancelBag: CancelBag!
    private var hasStarted: Bool = false
    private var isSplashAnimationCompleted: Bool = false
    private var isAuthBootstrapCompleted: Bool = false
    private var hasResolvedLaunchGate: Bool = false
    private var didResolveInitialAuthState: Bool = false
    private var wasLoggedInAtStartup: Bool = false
    
    init(launchService: LaunchScreenServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         impersonateService: ImpersonateServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         connectivityService: ConnectivityServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.launchService = launchService
        self.environmentService = environmentService
        self.apiService = apiService
        self.authService = authService
        self.impersonateService = impersonateService
        self.firebaseService = firebaseService
        self.appDelegateService = appDelegateService
        self.connectivityService = connectivityService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(appDelegate: AppDelegate) {
        
        self.appDelegateService
            .setup(appDelegate: appDelegate)
        
    }
    
    func setLaunchState(_ state: LaunchScreenService.State) {
        
        self.launchService
            .setState(state)
        
    }
    
    func markSplashAnimationCompleted() {
        
        self.log(message: "Launch gate: splash animation completed")
        self.isSplashAnimationCompleted = true
        resolveLaunchIfPossible()
        
    }
    
    func start(onLaunchStateChanged: @escaping (LaunchScreenService.State) -> Void,
               onImpersonationStateChanged: @escaping (Bool) -> Void,
               onAuthError: @escaping (Error) -> Void,
               onNoNetwork: @escaping () -> Void,
               onHealthCheckResult: @escaping (_ requiresForceUpdate: Bool) -> Void) {
        
        guard !self.hasStarted else { return }
        self.hasStarted = true
        
        self.cancelBag = CancelBag()
        
        self.firebaseService
            .userPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                
                guard let self else { return }
                guard !self.didResolveInitialAuthState else { return }
                
                self.didResolveInitialAuthState = true
                self.wasLoggedInAtStartup = (user != nil)
                
                if user == nil {
                    
                    self.isAuthBootstrapCompleted = true
                    self.log(message: "Launch gate: initial user is logged out")
                    self.resolveLaunchIfPossible()
                    return
                    
                }
                
                if self.authService.onInitialLoadCompleted.value {
                    
                    self.isAuthBootstrapCompleted = true
                    self.log(message: "Launch gate: initial user already bootstrapped")
                    self.resolveLaunchIfPossible()
                    
                }
                
            }
            .store(in: &self.cancelBag)
        
        self.authService
            .onInitialLoadCompleted
            .receiveOnMain()
            .sink { [weak self] didComplete in
                
                guard let self else { return }
                guard didComplete else { return }
                guard self.didResolveInitialAuthState else { return }
                guard self.wasLoggedInAtStartup else { return }
                
                self.isAuthBootstrapCompleted = true
                self.log(message: "Launch gate: logged-in bootstrap completed")
                self.resolveLaunchIfPossible()
                
            }
            .store(in: &self.cancelBag)
        
        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] environment in
                
                guard let self,
                      let environment else { return }
                
                self.runHealthCheck(for: environment) { requiresForceUpdate in
                    onHealthCheckResult(requiresForceUpdate)
                }
                
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
            .sink { error in
                
                guard let error else { return }
                onAuthError(error)
                
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
            .sink { state in
                onLaunchStateChanged(state)
            }
            .store(in: &self.cancelBag)
        
        self.connectivityService
            .onHasNetworkConnection
            .receiveOnMain()
            .sink { hasNetworkConnection in
                
                guard !hasNetworkConnection else { return }
                onNoNetwork()
                
            }
            .store(in: &self.cancelBag)
        
        self.viewLifecycleService
            .onWillEnterForeground
            .dropFirst(2)
            .receiveOnMain()
            .sink { [weak self] _ in
                
                Task {
                    await self?.refreshForegroundUserInfo()
                }
                
            }
            .store(in: &self.cancelBag)
        
        self.impersonateService
            .impersonatedUserPublisher
            .receiveOnMain()
            .sink { impersonatingUser in
                onImpersonationStateChanged(impersonatingUser != nil)
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func registerDeviceToken(_ token: String) {
        
        guard let user = self.authService.currentUser,
              self.firebaseService.user != nil else { return }
        
        Task { @MainActor [weak self] in
            
            do {
                
                try await self?.apiService.registerDevice(
                    token: token,
                    userId: user.id
                )
                
            }
            catch {
                
                self?.logError(
                    title: "Device Token Registration Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
    }
    
    private func resolveLaunchIfPossible() {
        
        guard !self.hasResolvedLaunchGate else { return }
        guard self.isSplashAnimationCompleted else { return }
        guard self.isAuthBootstrapCompleted else { return }
        
        self.hasResolvedLaunchGate = true
        self.log(message: "Launch gate: completed")
        
        self.launchService
            .setState(.completed)
        
    }
    
    private func runHealthCheck(for environment: AppEnvironment,
                                onHealthCheckResult: @escaping (_ requiresForceUpdate: Bool) -> Void) {
        
        guard environment != .development else { return }
        
        Task { @MainActor [weak self] in
            
            do {
                try await self?.apiService.getHealth()
            }
            catch {
                
                self?.logError(
                    title: "Health Check Error",
                    message: error.getMessageForError()
                )
                
                if let apiError = error as? APIError,
                   case let .serverError(statusCode, _) = apiError,
                   statusCode == 426 {
                    onHealthCheckResult(true)
                    return
                }
                
                onHealthCheckResult(false)
                
            }
            
        }
        
    }
    
    private func refreshForegroundUserInfo() async {
        
        do {
            try await self.authService.fetchUserInfoWithToken()
        }
        catch {
            
            self.logError(
                title: "Foreground User Refresh Error",
                message: error.getMessageForError()
            )
            
        }
        
    }
    
}

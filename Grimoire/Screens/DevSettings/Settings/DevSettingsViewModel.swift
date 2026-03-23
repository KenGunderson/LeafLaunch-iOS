//
//  DevSettingsViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI
import Combine

final class DevSettingsViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private let alertService: AlertServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    let firebaseService: FirebaseServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let impersonateService: ImpersonateServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private weak var navigationService: NavigationService?
    private var dismissAction: (() -> ())?
    private var cancelBag: CancelBag!
    private var logoutTask: Task<Void, Never>?
            
    @Published private(set) var user: GPUser?
    @Published private(set) var isCustomEnvSelected: Bool = false
    @Published var selectedEnviornment: AppEnvironment? = .development
    @Published var customAPIEnviornmentPath: String = Constants.URLs.defaultCustomEnvironmentAddress
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         impersonateService: ImpersonateServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.firebaseService = firebaseService
        self.appDelegateService = appDelegateService
        self.impersonateService = impersonateService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        
    }
    
    isolated deinit {
        cancelTasks()
        self.logDeinit()
    }
    
    func loadData() {
        
    }
    
    func setup(navigationService: NavigationService,
               dismissAction: @escaping (() -> ())) {
        
        self.navigationService = navigationService
        self.dismissAction = dismissAction
        
    }
    
    func navigate(to route: Route) {
        self.navigationService?.push(route)
    }
    
    func dismiss() {
        
        self.viewLifecycleService
            .reload(for: .devSettings)
        
        self.dismissAction?()
        
    }
    
    func set(environment: AppEnvironment) {
        
        self.environmentService.setEnvironment(environment)
        
        if !self.isCustomEnvSelected {
            self.customAPIEnviornmentPath = Constants.URLs.defaultCustomEnvironmentAddress
        }
        
    }
    
    @MainActor
    func copyAuthTokenToNotepad() {
            
        UIPasteboard.general.string = self.firebaseService.currentAccessToken ?? ""
        
        ToastManager.shared.present(toastItem: .init(
            title: "Auth Token Copied",
            titleColor: Style.shared.textColor(.title),
            message: "Your auth token is now saved on your clipboard",
            messageColor: Style.shared.textColor(.title),
            image: .systemImage("lock.fill"),
            tint: Style.shared.accent,
            isUserInteractionEnabled: true,
            timing: .medium,
            direction: .top
        ))
        
    }
    
    func getAppEnviornments() -> [AppEnvironment] {
        
        var appEnviornments: [AppEnvironment] = [.localhost, .development, .production]
        
        if case let .custom(address) = self.selectedEnviornment {
            appEnviornments.insert(.custom(address: address), at: 0)
        }
        else {
            appEnviornments.insert(.custom(address: Constants.URLs.defaultCustomEnvironmentAddress), at: 0)
        }
        
        return appEnviornments
        
    }
    
    func logout() {
        
        self.logoutTask?.cancel()
        self.dismiss()
        
        let authService = self.authService
        
        self.logoutTask = Task {
            
            do {
                try await authService.logout()
            }
            catch {
                guard !Task.isCancelled else { return }
            }
            
        }
        
    }
    
    var appVersion: String {
        return Constants.App.version
    }
    
    var buildNumber: String {
        return Constants.App.buildNumber
    }
    
    var bundleIdentifier: String {
        return Constants.App.bundleIdentifier
    }
    
    var currentEnvironmentName: String {
        return self.selectedEnviornment?.displayName ?? "Unavailable"
    }
    
    var deviceId: String {
        return Constants.Device.deviceId
    }
    
    var pushToken: String {
        return self.appDelegateService.deviceToken ?? "Unavailable"
    }
    
    var currentUserEmail: String {
        return self.user?.email ?? "Unavailable"
    }
    
    var impersonationState: String {
        
        guard self.impersonateService.isImpersonating else {
            return "Inactive"
        }
        
        return self.impersonateService.impersonatedUser?.email ?? "Active"
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] environment in
                
                guard let environment else { return }
                
                let selectedEnvName = environment.description
                let defaultEnvName = AppEnvironment.custom(address: "").description
                
                self?.isCustomEnvSelected = selectedEnvName == defaultEnvName
                self?.selectedEnviornment = environment
                
            }
            .store(in: &self.cancelBag)
        
        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func cancelTasks() {
        self.logoutTask?.cancel()
    }
    
}

extension DevSettingsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.settings))
    }
    
}

//
//  DevSettingsViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI
import Combine

final class DevSettingsViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private(set) var alertService: AlertServiceProtocol
    private(set) var authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private(set) var firebaseService: FirebaseServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var dismissAction: (() -> ())?
    private var cancelBag: CancelBag!
            
    @Published private(set) var user: GPUser?
    @Published private(set) var isCustomEnvSelected: Bool = false
    @Published var selectedEnviornment: AppEnvironment? = .development
    @Published var customAPIEnviornmentPath: String = Constants.URLs.defaultCustomEnvironmentAddress
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.firebaseService = firebaseService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        
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
        
        Task { [weak self] in
            
            self?.dismiss()
            
            try await self?.authService
                .logout()
            
        }
        
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
    
}

extension DevSettingsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.settings))
    }
    
}

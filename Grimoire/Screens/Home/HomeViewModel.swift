//
//  HomeViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/1/25.
//

import Foundation

final class HomeViewModel: ViewModel {
    
    internal let loggerName: String = "HOME_VIEW_MODEL"
    internal let loggerEmoji: String = "🏡"
    
    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let launchService: LaunchScreenServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var currentUser: GPUser?
    @Published private(set) var isFirstLoad: Bool = true
        
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         launchService: LaunchScreenServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.firebaseService = firebaseService
        self.launchService = launchService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        bindSubsribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func logout() {
        
        Task {
            try? await self.authService.logout()
        }
        
    }
    
    func bindSubsribers() {
        
        self.cancelBag = CancelBag()
        
        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &self.cancelBag)
        
        self.launchService
            .onLaunchStateChanged
            .receiveOnMain()
            .sink { [weak self] state in
                
                guard state == .completed else { return }
                guard let currentUser = self?.authService.currentUser else { return }
                
                self?.presentModalsIfNeeded(user: currentUser)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    func loadData(showHud: Bool = true) {
        
        guard let currentUser else { return }
        
        if self.firebaseService.isLoginContext || self.firebaseService.isSignUpContext {
            presentModalsIfNeeded(user: currentUser)
        }
                        
//        if showHud {
//            
//            self.alertService
//                .showAlert(.init(.simpleLoadingIndicator))
//            
//        }
            
//            if showHud {
//                
//                self.alertService
//                    .dismissLoadingIndicator()
//                
//            }
//            
//        }
        
    }
    
    private func presentModalsIfNeeded(user: GPUser) {
                
        self.navigationService?.popToRoot()
        
        let shouldShowOnboarding = !self.userDefaultsService.didCompleteOnboarding
        
        if shouldShowOnboarding {
            
            self.logger.debug("Attemping to show onboarding modal")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                
                self.navigationService?
                    .modal(fullScreenCover: .onboarding)
                
            })
            
        }
        
    }
    
}

extension HomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .home)
    }
    
}

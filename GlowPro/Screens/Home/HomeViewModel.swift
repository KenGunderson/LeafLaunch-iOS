//
//  HomeViewModel.swift
//  GlowPro
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
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let launchService: LaunchScreenServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var currentUser: GPUser?
    @Published private(set) var pendingInvites: [EmployeeInvite] = []
    @Published private(set) var workspaces: [Workspace] = []
    @Published private(set) var isFirstLoad: Bool = true
    
    var hasActiveBusiness: Bool {
        return self.workspaces.contains(where: { $0.isOwner })
    }
    
    var hasActiveWorkspace: Bool {
        return self.workspaces.count > 0
    }
    
    var hasRoleLocations: Bool {
        
        let roleLocations = self.workspaces.map { $0.roleLocations }
        return !roleLocations.isEmpty
        
    }
        
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         launchService: LaunchScreenServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
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
    
    func setActiveDestination(_ destination: ActiveDestination?) {
        
        if let destination {
            
            self.activeDestinationService
                .setActiveDestination(destination)
            
        } else {
            
            self.activeDestinationService
                .removeActiveDestination()
            
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
        
        if self.firebaseService.isNewUserContext {
            presentModalsIfNeeded(user: currentUser)
        }
                        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
                        
            do {
                
                let workspaces = try await self.apiService.getWorkspaces(userId: currentUser.id)
                let pendingInvites = try await self.apiService.getPendingInvitesForUser(email: currentUser.email)
                                
                await MainActor.run { [weak self] in

                    self?.isFirstLoad = false
                    self?.workspaces = workspaces
                    self?.pendingInvites = pendingInvites
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("information"),
                            action: {})
                    ))
                )
                
            }
            
            if showHud {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
        }
        
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

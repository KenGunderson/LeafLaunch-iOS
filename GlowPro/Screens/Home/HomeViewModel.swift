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
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var currentUser: GPUser?
    @Published private(set) var pendingInvites: [EmployeeInvite] = []
    @Published private(set) var workspaces: [Workspace] = []
        
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
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
        
    }
    
    func loadData(showHud: Bool = true) {
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                
                let workspaces = try await self.apiService.getWorkspaces()
                let pendingInvites = try await self.apiService.getPendingInvitesForUser()
                
                await MainActor.run { [weak self] in

                    self?.workspaces = workspaces
                    self?.pendingInvites = pendingInvites
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.errorMessage("information"),
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
    
}

extension HomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .home)
    }
    
}

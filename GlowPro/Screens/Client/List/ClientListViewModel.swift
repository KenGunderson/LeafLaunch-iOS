//
//  ClientListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import Foundation

final class ClientListViewModel: ViewModel {
    
    internal let loggerName: String = "CLIENT_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var groupedClientsDict: [Character: [Client]] = [:]
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let clients = try await self.apiService.getClients(businessId: MockModels.ID.business1)
                let usersByFirstLetter = Dictionary(grouping: clients) { (client: Client) -> Character in
                    return client.firstName.first ?? "?"
                }
                
                await MainActor.run { [weak self] in
                    self?.groupedClientsDict = usersByFirstLetter
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while fetching your clients. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func selectClient(_ client: Client) {
        
        self.tabBarNavigationService?
            .currentNavigationService()
            .modal(fullScreenCover: .clientDetails(clientId: client.id))
        
    }
    
    func dismiss() {
        
        self.tabBarNavigationService?
            .currentNavigationService()
            .pop()
        
    }
    
}

extension ClientListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientList))
    }
    
}

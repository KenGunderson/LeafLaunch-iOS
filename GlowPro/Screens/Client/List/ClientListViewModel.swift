//
//  ClientListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import Foundation

final class ClientListViewModel: ViewModel {
    
    enum Context: Hashable {
        
        case business(businessId: String)
        case location(locationId: String)
        
    }
    
    internal let loggerName: String = "CLIENT_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var groupedClientsDict: [Character: [Client]] = [:]
    
    private var context: Context!
    
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
    
    @discardableResult
    func setup(context: Context) -> Self {
        
        self.context = context
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                var clients: [Client] = []
                
                switch context {
                case .business(let businessId):
                    
                    clients = try await self.apiService.getClients(businessId: businessId)
                    
                case .location(let locationId):
                    
                    clients = try await self.apiService.getClients(locationId: locationId)
                    
                default: break
                }
                
                
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
        
        self.navigationService?
            .modal(fullScreenCover: .clientDetails(clientId: client.id))
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
}

extension ClientListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientList))
    }
    
}

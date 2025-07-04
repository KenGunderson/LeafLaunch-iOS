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
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var groupedClientsDict: [Character: [Client]] = [:]
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.analyticsService = analyticsService
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
        
        let clients: [Client] = [
            .init(id: "1", firstName: "Sako", lastName: "Hovaguimian", email: "sako@me.com", phone: "818-522-5755", birthDate: Date().ISO8601Format()),
            .init(id: "2", firstName: "Leon", lastName: "Hovaguimian", email: "leon@me.com", phone: "818-522-5755", birthDate: Date().ISO8601Format()),
            .init(id: "3", firstName: "KC", lastName: "Gunderson", email: "kc@me.com", phone: nil),
            .init(id: "4", firstName: "John", lastName: "Sharpe", email: nil, phone: nil),
            .init(id: "5", firstName: "Robert", lastName: "Sharpe", email: nil, phone: nil),
            .init(id: "6", firstName: "Mitch", lastName: "Treece", email: nil, phone: nil),
            .init(id: "7", firstName: "Dan", lastName: "Winkle", email: nil, phone: nil),
            .init(id: "8", firstName: "Sean", lastName: "Wing", email: nil, phone: nil),
            .init(id: "9", firstName: "Bobby", lastName: "Hill", email: nil, phone: nil),
            .init(id: "10", firstName: "Anakin", lastName: "Skywalker", email: nil, phone: nil),
        ]
        
        let usersByFirstLetter = Dictionary(grouping: clients) { (client: Client) -> Character in
            return client.firstName.first ?? "?"
        }
        
        self.groupedClientsDict = usersByFirstLetter
        
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

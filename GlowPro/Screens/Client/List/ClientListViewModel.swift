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
        
        var isBusinessContext: Bool {
            switch self {
            case .business: return true
            case .location: return false
            }
        }
        
        var isLocationContext: Bool {
            switch self {
            case .business: return false
            case .location: return true
            }
        }
        
    }
    
    internal let loggerName: String = "CLIENT_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "👤"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var groupedClientsDict: [Character: [Client]] = [:]
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private(set) var context: Context!
    
    var isLocationContext: Bool {
        return self.context.isLocationContext
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        self.bindSubscribers()
        
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
    
    func loadData(showHud: Bool = true) {
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
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
                
                await MainActor.run { [weak self, clients] in
                    
                    self?.groupedClientsDict = usersByFirstLetter
                    self?.shouldShowEmptyState = clients.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("clients"),
                            action: {
                                
                                self.navigationService?
                                    .pop()
                                
                            })
                    ))
                )
                
            }
            
            if showHud {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
        }
        
    }
    
    func selectClient(_ client: Client) {
        
        self.navigationService?
            .push(.client(.clientHome(clientId: client.id)))
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Clients Found",
            message: "Start building your client base by adding your first client",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Client",
            action: { [weak self] in
                
                switch self?.context {
                case .business(_):
                    
                    let hasLocation = !(self?.activeDestinationService.business?.locations.isEmpty ?? true)
                    
                    if hasLocation {
                        
                        self?.navigationService?
                            .push(.client(.clientCreate(
                                locationId: self?.activeDestinationService.business?.locations.first?.id ?? "",
                                clientId: nil
                            )))
                        
                    } else {
                        self?.presentChecklistClientMediaErrorAlert()
                    }
                    
                case .location(let locationId):
                    
                    self?.navigationService?
                        .push(.client(.clientCreate(locationId: locationId)))
                
                default: break
                }
            })
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .clientList)
            .sink { [weak self] in
                self?.loadData(showHud: false)
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentChecklistClientMediaErrorAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Hold up!",
                message: "You need to create a location before you can add clients or create media.",
                primaryButtonTitle: "Okay",
                primaryButtonAction: {},
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted)
            ))))
        
    }
    
}

extension ClientListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .client(.clientList))
    }
    
}

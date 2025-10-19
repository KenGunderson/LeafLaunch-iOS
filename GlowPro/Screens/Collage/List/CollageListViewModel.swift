//
//  CollageListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import Foundation

final class CollageListViewModel: ViewModel {
    
    internal let loggerName: String = "COLLAGE_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "🎞️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var collages: [Collage] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private(set) var context: MediaContext!
    
    var allowsCollageCreation: Bool {
        switch self.context! {
        case .business: false
        case .location: false
        case .client: true
        case .employee: false
        }
    }
    
    var clientId: String {
        switch self.context! {
        case .business: return ""
        case .location: return ""
        case .client(let clientId): return clientId
        case .employee: return ""
        }
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
    func setup(context: MediaContext) -> Self {
        
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
                
                var collages: [Collage] = []
                
                switch self.context! {
                case .business(let businessId):
                    
                    collages = try await self.apiService.getCollage(businessId: businessId)
                    
                case .location(let locationId):
                
                    collages = try await self.apiService.getCollage(locationId: locationId)
                    
                case .client(let clientId):
                    
                    collages = try await self.apiService.getCollage(clientId: clientId)
                    
                case .employee:
                    collages = []
                }
                
                await MainActor.run { [weak self, collages] in
                    
                    self?.collages = collages
                    self?.shouldShowEmptyState = collages.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("collages"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
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
    
    func selectCollage(_ client: Client) {
        
        // TODO: - IMPLEMENT
        
//        self.navigationService?
//            .push(.client(.clientHome(clientId: client.id)))
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Collages Found",
            message: "Collages are a great way to organize your photos. Click the button below to add your first one.",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Collage",
            action: { [weak self] in
                
                // TODO: later
                
//                self?.navigationService?
//                    .push(
//                        .note(.noteCreateEdit(
//                            context: .create,
//                            clientId: self?.clientId ?? ""
//                        ))
//                    )
                
            })
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .collageList)
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.loadData(showHud: false)
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension CollageListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .collage(.collageList))
    }
    
}

//
//  BusinessActivityListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/25.
//

import Foundation

final class BusinessActivityListViewModel: ViewModel {
    
    enum Context: Hashable {
        
        case business(businessId: String)
        case location(locationId: String)
        case employee(employeeId: String)
        case client(clientId: String)
        
        var identifier: String {
            switch self {
            case .business(let businessId): return businessId
            case .location(let locationId): return locationId
            case .employee(let employeeId): return employeeId
            case .client(let clientId): return clientId
            }
        }
        
        var analyticsName: String {
            switch self {
            case .business: return "business"
            case .location: return "location"
            case .employee: return "employee"
            case .client: return "client"
            }
        }
        
    }
    
    internal let loggerName: String = "ACTIVITY_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    @Published private(set) var selectedActivityTypes: [ActivityType] = []
    
    private var isLoading: Bool = false
    private var isPagingComplete: Bool = false
    
    private(set) var context: Context!
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
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
    
    func loadData(showsHUD: Bool = true) {
        
        guard !self.isLoading else { return }
        guard !self.isPagingComplete else { return }
        
        self.isLoading = true
        
        if showsHUD {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                
                var activities: [Activity] = []
                
                let query = Query(
                    limit: Query.defaultLimit,
                    offset: self.activities.count
                )
                
                switch context {
                case .business(let businessId):
                    
                    activities = try await self.apiService
                        .getActivitiy(
                            businessId: businessId,
                            query: query,
                            activityTypeFilters: self.selectedActivityTypes
                        )
                    
                case .location(let locationId):
                    
                    activities = try await self.apiService
                        .getActivitiy(
                            locationId: locationId,
                            query: query,
                            activityTypeFilters: self.selectedActivityTypes
                        )
                    
                case .employee(let employeeId):
                    
                    activities = try await self.apiService
                        .getActivitiy(
                            employeeId: employeeId,
                            query: query,
                            activityTypeFilters: self.selectedActivityTypes
                        )
                    
                case .client(let clientId):
                    
                    activities = try await self.apiService
                        .getActivitiy(
                            clientId: clientId,
                            query: query,
                            activityTypeFilters: self.selectedActivityTypes
                        )
                    
                default: break
                }
                
                await MainActor.run { [activities] in
                    
                    self.activities += activities
                    self.isPagingComplete = activities.count < Query.defaultLimit
                    self.shouldShowEmptyState = activities.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("activities"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            if showsHUD {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            
        }
        
    }
    
    func set(activityType: ActivityType) {
        
        if self.selectedActivityTypes.contains(activityType) {
            self.selectedActivityTypes.removeAll { $0 == activityType }
        }
        else {
            self.selectedActivityTypes.append(activityType)
        }
        
        self.resetPagingState()
        self.loadData(showsHUD: false)
        
    }
    
    func clearFilters() {
        
        self.selectedActivityTypes.removeAll()
        self.resetPagingState()
        self.loadData(showsHUD: false)
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Activities",
            message: "As you interact with the app we will add new activities to this list",
            image: .systemImage("magnifyingglass"),
            actionTitle: nil,
            action: nil
        )
        
    }
    
    private func resetPagingState() {
        
        self.isPagingComplete = false
        self.activities = []
        
    }
    
    private func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessActivityListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessActivityList(context: self.context)))
    }
    
}

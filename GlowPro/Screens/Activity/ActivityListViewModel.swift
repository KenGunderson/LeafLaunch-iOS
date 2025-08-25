//
//  ActivityListViewModel.swift
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
        
        var identifier: String {
            switch self {
            case .business(let businessId): return businessId
            case .location(let locationId): return locationId
            case .employee(let employeeId): return employeeId
            }
        }
        
        var analyticsName: String {
            switch self {
            case .business: return "business"
            case .location: return "location"
            case .employee: return "employee"
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
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
//                var employeeInvites: [EmployeeInvite] = []
//                
//                switch context {
//                case .personal:
//                    
//                    employeeInvites = try await self.apiService
//                        .getPendingInvitesForUser()
//                    
//                case .business(let businessId):
//                    
//                    employeeInvites = try await self.apiService
//                        .getEmployeeInvites(businessId: businessId)
//                
//                default: break
//                }
//                
//                await MainActor.run { [employeeInvites] in
//                    
//                    self.employeeInvites = employeeInvites
//                    self.shouldShowEmptyState = employeeInvites.isEmpty
//                    
//                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.errorMessage("activities"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
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

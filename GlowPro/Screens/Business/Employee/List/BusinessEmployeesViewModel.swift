//
//  BusinessEmployeesViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessEmployeesViewModel: ViewModel {
    
    public enum Context: Hashable {
        
        case business(businessId: String)
        case location(locationId: String)
        
        var analyticsName: String {
            switch self {
            case .business: return "business"
            case .location: return "location"
            }
        }
        
        var analyticsId: String {
            switch self {
            case .business(businessId: let businessId): return businessId
            case .location(locationId: let locationId): return locationId
            }
        }
        
    }
    
    internal let loggerName: String = "BUSINESS_EMPLOYEES_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    @Published private(set) var employees: [Employee] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private var businessId: String!
    private var context: Context!

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
    func setup(businessId: String,
               context: Context) -> Self {
        
        self.businessId = businessId
        self.context = context
        return self
        
    }
    
    func selectEmployee(_ employee: Employee) {
        
        navigate(to: .business(.businessEmployeeDetails(
            businessId: self.businessId,
            employeeId: employee.id
        )))
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                var employees: [Employee] = []
                var business = try await self.apiService
                    .getBusiness(id: self.businessId)
                
                switch self.context {
                case .business(let businessId):
                
                    employees = try await self.apiService
                        .getEmployees(businessId: businessId)
                    
                case .location(let locationId):
                    
                    employees = try await self.apiService
                        .getEmployees(locationId: locationId)
                    
                default: break
                }
                
                await MainActor.run { [weak self, business, employees] in

                    self?.business = business
                    self?.employees = employees
                    self?.shouldShowEmptyState = employees.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.errorMessage("employees"),
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
            title: "No Employees Found",
            message: "Start building your business by inviting your first employee",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Invite Your First Employee",
            action: {
                
                self.navigationService?
                    .push(.business(.businessEmployeesInvite(businessId: self.businessId)))
                
            }
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

extension BusinessEmployeesViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessEmployees(context: self.context)))
    }
    
}

//
//  BusinessEmployeeInviteListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessEmployeeInviteListViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_EMPLOYEES_INVITE_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var employeeInvites: [EmployeeInvite] = []
    
    private var businessId: String!

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
    func setup(businessId: String) -> Self {
        
        self.businessId = businessId
        return self
        
    }
    
    func selectEmployee(_ employee: Employee) {
        
        navigate(to: .business(.businessEmployeeDetails(
            businessId: self.businessId,
            employeeId: employee.id)
        ))
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let employeeInvites = try await self.apiService
                    .getEmployeeInvites(businessId: self.businessId)
                
                await MainActor.run { [weak self] in
                    self?.employeeInvites = employeeInvites
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while fetching your employees. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func acceptInvite(_ invite: EmployeeInvite) {
        print("Accept Invite")
    }
    
    func denyInvite(_ invite: EmployeeInvite) {
        print("Deny Invite")
    }
    
    private func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessEmployeeInviteListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessEmployeeInviteList(businessId: self.businessId)))
    }
    
}

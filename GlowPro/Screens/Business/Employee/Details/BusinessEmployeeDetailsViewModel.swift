//
//  BusinessEmployeeDetailsViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessEmployeeDetailsViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_EMPLOYEE_DETAILS_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var employee: Employee?
    @Published private(set) var activeLocations: [Workspace.RoleLocation] = []
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var media: [Media] = []
    
    @Published private(set) var isFirstLoad: Bool = true
    
    private(set) var businessId: String!
    private(set) var employeeId: String!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
        
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var isEmployeeOwnerOrManager: Bool {
        return self.activeDestinationService.business?.owner.id == self.employee?.userId
    }
        
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(businessId: String,
               employeeId: String) -> Self {
        
        self.businessId = businessId
        self.employeeId = employeeId
        
        return self
        
    }
    
    func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
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
                
                let employee = try await self.apiService
                    .getEmployee(id: self.employeeId)
                
                let media = try await self.apiService
                    .getMedia(
                        authorId: self.employeeId,
                        sortingOption: .newest,
                        filterOption: .image,
                        tags: []
                    )
                
                let activities = try await self.apiService
                    .getActivitiy(
                        employeeId: self.employeeId,
                        query: .init(),
                        activityTypeFilters: []
                    )
                
                let workspaces = try await self.apiService
                    .getWorkspaces(userId: employee.userId)
                
                await MainActor.run { [weak self] in

                    self?.employee = employee
                    self?.media = media
                    self?.activities = activities
                    self?.isFirstLoad = false
                    
                    let roleLocations =  workspaces
                        .filter({ $0.id == self?.businessId })
                        .flatMap({ $0.roleLocations })
                    
                    self?.activeLocations = roleLocations
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("employee details"),
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
    
    func presentDeleteEmployeeAlert() {
                
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Employee"),
                message: Constants.Message.deleteConfirmationMessage("employee"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteEmployee()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteEmployee() {
        
        Task {
            
            do {
                
                try await self.apiService
                    .deleteEmployee(id: self.employeeId)
                
                await MainActor.run { [weak self] in
                    self?.navigationService?.pop()
                }
                
            }
            catch {
                
                self.alertService
                    .showAlert(.init(.appAlert(.error(
                        message: Constants.Message.errorMessage(context: .delete, "employee"),
                        action: {})
                    )))
                
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessEmployeeDetailsViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessEmployeeDetails(
            businessId: self.businessId,
            employeeId: self.employeeId
        )))
        
    }
    
}

//
//  BusinessEmployeeUpdateViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import Foundation

final class BusinessEmployeeUpdateViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_EMPLOYEE_UPDATE_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var employee: Employee?
    
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var selectedRole: Role? = .employee
    
    var isSaveButtonEnabled: Bool {
        return (self.selectedRole != nil)
    }
    
    private var businessId: String!
    private var employeeId: String!

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
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {

                let employee = try await self.apiService
                    .getEmployee(id: self.employeeId)
                
                await MainActor.run { [weak self] in
                    self?.employee = employee
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("business"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func updateEmployee() {
        
        self.alertService
            .showAlert(.init(.appAlert(.success(message: "Updated successfully! Your changes have been saved.", action: {
                
                self.navigationService?
                    .popWithDelay()
                
            }))))
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessEmployeeUpdateViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessEmployeeUpdate(
            businessId: self.businessId,
            employeeId: self.employeeId
        )))
        
    }
    
}

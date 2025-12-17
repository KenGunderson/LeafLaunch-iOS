//
//  BusinessEmployeeInviteListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessEmployeeInviteListViewModel: ViewModel {
    
    enum Context: Hashable {

        case personal
        case business(businessId: String)
        
    }
    
    internal let loggerName: String = "EMPLOYEE_INVITE_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var employeeInvites: [EmployeeInvite] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    @Published private(set) var isFirstLoad: Bool = true
    
    private(set) var context: Context!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    private var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var shouldShowAddEmployeeButton: Bool {
        return self.isOwnerOrManager && self.context != .personal
    }
    
    var businessId: String {
        return self.activeDestinationService.businessId ?? ""
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
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
    
    func loadData(showHud: Bool = true) {
        
        guard let currentUser = self.authService.currentUser else { return }
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                
                var employeeInvites: [EmployeeInvite] = []
                
                switch context {
                case .personal:
                    
                    employeeInvites = try await self.apiService
                        .getPendingInvitesForUser(email: currentUser.email)
                    
                case .business(let businessId):
                    
                    employeeInvites = try await self.apiService
                        .getEmployeeInvites(businessId: businessId)
                
                default: break
                }
                
                self.viewLifecycleService.reload(for: .businessHome)
                
                await MainActor.run { [weak self, employeeInvites] in
                    
                    self?.isFirstLoad = false
                    self?.employeeInvites = employeeInvites
                    self?.shouldShowEmptyState = employeeInvites.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("employees"),
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
    
    func acceptInvite(_ invite: EmployeeInvite) {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                try await self.apiService
                    .acceptEmployeeInvite(invite: invite)
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while accepting your invite. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData()
            
        }
        
    }
    
    func denyInvite(_ invite: EmployeeInvite) {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
     
        Task {
            
            do {
                
                try await self.apiService
                    .declineEmployeeInvite(invite: invite)
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while declining your invite. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData()
            
        }
        
    }
    
    func presentDeleteEmployeeInviteAlert(_ invite: EmployeeInvite) {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Delete Employee Invite?",
                message: "You are attemping to delete \(invite.name)'s employee invite. This action cannot be undone. Are you sure you wish to continue?",
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        self?.deleteInvite(invite)
                    }
                    
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteInvite(_ invite: EmployeeInvite) {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                try await self.apiService
                    .deleteEmployeeInvite(invite: invite)
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .delete, "employee invite"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData()
            
        }
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        switch self.context! {
        case .business(let businessId):
            return .init(
                title: "No Pending Invites",
                message: "Start inviting employees to join your business by clicking the button below",
                image: .systemImage("magnifyingglass"),
                actionTitle: "Add Your First Employee",
                action: {
                    
                    self.navigationService?
                        .push(.business(
                            .businessEmployeesInvite(
                                businessId: businessId,
                                context: .newEmployee
                            )))
                    
                }
            )
            
        case .personal:
            
            return .init(
                title: "No Pending Invites",
                message: "Come back from time to time to see if there any new invites",
                image: .systemImage("magnifyingglass"),
                actionTitle: nil,
                action: nil
            )
        }
        
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
        self.analyticsService.track(screen: .business(.businessEmployeeInviteList(context: self.context)))
    }
    
}

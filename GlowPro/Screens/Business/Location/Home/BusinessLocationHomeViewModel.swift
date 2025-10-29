//
//  BusinessLocationHomeViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import Foundation
import UIKit

final class BusinessLocationHomeViewModel: ViewModel {
    
    internal let loggerName: String = "LOCATION_HOME_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var currentUser: GPUser?
    @Published private(set) var business: Business?
    @Published private(set) var location: Location?
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var pendingInvites: [EmployeeInvite] = []
    
    @Published var shouldShowSecurityScreen: Bool = false
    
    private(set) var locationId: String!
    private(set) var completion: (() -> ())?
    
    var isFirstLoad: Bool = true
    
    var isOwner: Bool {
        return self.activeDestinationService.isOwner
    }
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    init(authService: AuthServiceProtocol,
         apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        bindSubsribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(locationId: String,
               completion: (() -> ())?) -> Self {
        
        self.locationId = locationId
        self.completion = completion
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func bindSubsribers() {
        
        self.cancelBag = CancelBag()
        
        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &self.cancelBag)
        
    }
    
    func loadData(showHud: Bool = true) {
        
        guard let currentUser = self.authService.currentUser?.id else { return }
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                                
                async let activities = self.apiService.getActivitiy(
                    locationId: self.locationId,
                    query: .init(),
                    activityTypeFilters: []
                )
                
                async let employeeId = self.apiService.getEmployeeByUserIdForLocation(
                    userId: currentUser.id,
                    locationId: self.locationId
                )

                let location = try await self.apiService.getLocation(id: self.locationId)

                async let business = self.apiService.getBusiness(id: location.businessId)

                let resolvedEmployeeId = try await employeeId
                let locationEmployee = try await self.apiService.getLocationEmployee(
                    employeeId: resolvedEmployeeId,
                    locationId: self.locationId
                )

                let resolvedBusiness = try await business
                let resolvedActivities = try await activities

                self.activeDestinationService.setActiveDestination(
                    .location(
                        locationId: self.locationId,
                        location: location,
                        locationEmployee: locationEmployee,
                        business: resolvedBusiness
                    )
                )
                
                await MainActor.run { [weak self] in
                    
                    self?.isFirstLoad = false
                    self?.business = resolvedBusiness
                    self?.activities = resolvedActivities
                    self?.pendingInvites = resolvedBusiness.employeeInvites
                    self?.location = location
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("location"),
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
    
    func showSecurityPinSheetIfNeeded() {
        
        guard self.userDefaultsService.getSecurityPinForBusinessId(self.business?.id ?? "") != nil else {
            
            dismiss()
            return
            
        }
        
        self.shouldShowSecurityScreen = true
        
    }
    
    func dismiss() {
        
        self.completion?()
        self.navigationService?.pop()
        
    }
    
    func presentDeleteEmployeeInviteAlert(_ invite: EmployeeInvite) {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Delete Employee Invite?",
                message: "You are attemping to delete \(invite.name)'s employee invite. This action cannot be undone. Are you sure you wish to continue?",
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteInvite(invite)
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
                            message: "Something went wrong while deleting your employee invite. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData(showHud: false)
            
        }
        
    }
    
}

extension BusinessLocationHomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessLocationHome(locationId: self.locationId)))
    }
    
}

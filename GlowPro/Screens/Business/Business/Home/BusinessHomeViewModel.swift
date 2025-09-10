//
//  BusinessHomeViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import Foundation

final class BusinessHomeViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_HOME_VIEW_MODEL"
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
    @Published private(set) var checklistItems: [ChecklistView.ChecklistItem] = []
    
    @Published var shouldShowChecklistCompletionSheet: Bool = false
    
    var isFirstLoad: Bool = true

    private(set) var businessId: String!
    
    var showChecklist: Bool {
        return !self.checklistItems.map({ $0.isComplete }).allSatisfy({ $0 })
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
    func setup(businessId: String) -> Self {
        
        self.businessId = businessId
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
    
    func loadData(showsLoadingIndicator: Bool = true) {
        
        if showsLoadingIndicator {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                
                self.activeDestinationService.refresh()
                
                let business = try await self.apiService.getBusiness(id: self.businessId)
                
                await MainActor.run { [weak self] in
                    
                    self?.isFirstLoad = false
                    self?.business = business
                    
                    let hasLocations = ((self?.business?.totalLocationCount ?? 0) > 0)
                    let hasClients = ((self?.business?.totalClientCount ?? 0) > 0)
                    let hasMedia = ((self?.business?.totalMediaCount ?? 0) > 0)
                    
                    self?.checklistItems = [
                        .init(type: .completeProfile, isComplete: true),
                        .init(type: .createLocation, isComplete: hasLocations),
                        .init(type: .createClient, isComplete: hasClients),
                        .init(type: .createMedia, isComplete: hasMedia),
                    ]
                    
                    if let didView = self?.userDefaultsService.didViewChecklistCompletionSheet,
                       !didView,
                       hasLocations,
                       hasClients,
                       hasMedia{
                        
                        self?.shouldShowChecklistCompletionSheet = true
                        
                        self?.userDefaultsService
                            .set(didViewChecklistCompletionSheet: true)
                        
                    }
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("business"),
                            action: {
                                
                                self.navigationService?
                                    .pop()
                                
                            })
                    ))
                )
                
            }
            
            if showsLoadingIndicator {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
        }
        
    }
    
    func selectChecklistType(type: ChecklistView.ChecklistItemType) {
        
        guard let business else { return }
        
        switch type {
        case .completeProfile: break
        case .createLocation: self.navigationService?.push(.business(.businessLocationCreateEdit(businessId: self.businessId, locationId: nil)))
        case .createClient:
            
            if business.locations.isEmpty {
                
                presentChecklistClientMediaErrorAlert()
                return
                
            }
            
            self.navigationService?
                .push(.client(.clientCreate(locationId: self.business?.locations.first?.id ?? "", clientId: nil)))
            
        case .createMedia:
            
            if business.locations.isEmpty {
                
                presentChecklistClientMediaErrorAlert()
                return
                
            }
            
            self.navigationService?
                .push(.media(.camera(
                    context: .business(businessId: self.businessId),
                    mode: .multiple([])
                )))
        }
        
    }
    
    func presentChecklistClientMediaErrorAlert() {
        
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
            
            loadData(showsLoadingIndicator: false)
            
        }
        
    }
    
}

extension BusinessHomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessHome(businessId: self.businessId)))
    }
    
}

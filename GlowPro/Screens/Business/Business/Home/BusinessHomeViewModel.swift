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
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var currentUser: GPUser?
    @Published private(set) var business: Business?
    @Published private(set) var checklistItems: [ChecklistView.ChecklistItem] = []
    @Published private(set) var activities: [Activity] = []
    
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
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.authService = authService
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
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
        
        self.viewLifecycleService
            .publisher(for: .businessHome)
            .sink { [weak self] in
                self?.loadData(showHud: false)
            }
            .store(in: &self.cancelBag)
        
    }
    
    func loadData(showHud: Bool = true) {
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                                
                let business = try await self.apiService.getBusiness(id: self.businessId)
                let activities = try await self.apiService.getActivitiy(
                    businessId: self.businessId,
                    query: .init(limit: 10),
                    activityTypeFilters: []
                )
                
                await MainActor.run { [weak self, business] in
                    
                    self?.isFirstLoad = false
                    self?.activities = activities
                    
                    let hasLocations = ((business.totalLocationCount) > 0)
                    let hasClients = ((business.totalClientCount) > 0)
                    let hasMedia = ((business.totalMediaCount) > 0)
                    
                    self?.checklistItems = [
                        .init(type: .completeProfile, isComplete: true),
                        .init(type: .createLocation, isComplete: hasLocations),
                        .init(type: .createClient, isComplete: hasClients),
                        .init(type: .createMedia, isComplete: hasMedia),
                    ]
                    
                    self?.business = business
                    
                    self?.activeDestinationService
                        .setActiveDestination(.business(
                            businessId: business.id,
                            business: business)
                        )
                    
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
    
    func selectChecklistType(type: ChecklistView.ChecklistItemType) {
        
        guard let business else { return }
        
        switch type {
        case .completeProfile: break
        case .createLocation: self.navigationService?.push(.business(.businessLocationCreateEdit(businessId: self.businessId, locationId: nil)))
        case .createClient:
            
            if business.locations.isEmpty {
                
                presentChecklistClientAlert()
                return
                
            }
            
            presentChecklistClientAlert()
            
        case .createMedia:
            
            if business.locations.isEmpty {
                
                presentChecklistClientMediaErrorAlert()
                return
                
            }
            
            presentChecklistMediaAlert()
            
        }
        
    }
    
    @MainActor
    func presentSubscriptionPaywall() {
        
        guard let business else { return }
        guard let navigationService else { return }
        
        if business.isSubscribed {
            
            navigationService
                .modal(fullScreenCover: .subscriptionManage(businessId: business.id))
            
        } else {
            
            navigationService
                .modal(fullScreenCover: .subscriptionPaywall(
                    context: .create,
                    paywallItem: .GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION,
                    completion: nil
                ))
            
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
    
    func presentChecklistClientAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Select A Location",
                message: "Clients can only be created inside a location. Use the Dashboard to oversee your business, and Locations to handle daily operations.",
                primaryButtonTitle: "Got It",
                primaryButtonAction: {},
                primaryButtonBackgroundColor: Style.shared.accent,
                primaryButtonTextColor: Style.shared.textColor(.titleInverted)
            ))))
        
    }
    
    func presentChecklistMediaAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Select A Client",
                message: "Photos can only be taken for a client. Choose a client to continue. You can always view all media in the Dashboard.",
                primaryButtonTitle: "Got It",
                primaryButtonAction: {},
                primaryButtonBackgroundColor: Style.shared.accent,
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
            
            loadData(showHud: false)
            
        }
        
    }
    
}

extension BusinessHomeViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessHome(businessId: self.businessId)))
    }
    
}

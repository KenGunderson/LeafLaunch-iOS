//
//  BusinessLocationCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import Foundation

final class BusinessLocationCreateEditViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_LOCATION_CREATE_EDIT_VIEW_MODEL"
    internal let loggerEmoji: String = "🏰"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var business: Business?
    
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var street: String = ""
    @Published var street2: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zip: String = ""
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.name.isEmpty &&
            !self.phone.isEmpty &&
            !self.email.isEmpty &&
            !self.street.isEmpty &&
            !self.city.isEmpty &&
            !self.state.isEmpty &&
            !self.zip.isEmpty
        )
        
    }
    
    var navTitle: String {
        return self.locationId == nil ? "Create Location" : "Edit Location"
    }
    
    private var businessId: String!
    private var locationId: String?

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
               locationId: String?) -> Self {
        
        self.businessId = businessId
        self.locationId = locationId
        
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
                
                let business = try await self.apiService
                    .getBusiness(id: self.businessId)
                
                var location: Location?
                
                if let locationId {
                    
                    location = try await self.apiService
                        .getLocation(id: locationId)
                    
                }
                
                await MainActor.run { [weak self, location] in
                    
                    self?.business = business
                    self?.name = location?.name ?? ""
                    self?.phone = location?.phone ?? ""
                    self?.email = location?.email ?? ""
                    self?.street = location?.address.street ?? ""
                    self?.street2 = location?.address.street2 ?? ""
                    self?.city = location?.address.city ?? ""
                    self?.state = location?.address.state ?? ""
                    self?.zip = location?.address.zip ?? ""
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while fetching your business. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func save() {
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessLocationCreateEditViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .business(.businessLocationCreateEdit(
            businessId: self.businessId,
            locationId: self.locationId
        )))
        
    }
    
}

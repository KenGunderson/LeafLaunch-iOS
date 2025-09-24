//
//  BusinessCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

final class BusinessCreateEditViewModel: ViewModel {
    
    internal let loggerName: String = "BUSINESS_CREATE_EDIT_VIEW_MODEL"
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
    @Published var zip: String = ""
    
    @Published var selectedCategories: [BusinessCategory] = []
    @Published var selectedSubcategories: [BusinessSubcategory] = []
    
    @Published var selectedState: Constants.USState?
    
    private var businessId: String?

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isCreateContext: Bool {
        return self.businessId == nil
    }
    
    var isSubmitButtonEnabled: Bool {
        
        return (
            !self.name.isEmpty &&
            !self.email.isEmpty &&
            self.email.isValidEmail() &&
            !self.street.isEmpty &&
            !self.city.isEmpty &&
            !self.zip.isEmpty &&
            self.selectedState != nil
        )
        
    }
    
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
    func setup(businessId: String?) -> Self {
        
        self.businessId = businessId
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
        
        guard let businessId else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let business = try await self.apiService
                    .getBusiness(id: businessId)
                
                await MainActor.run { [weak self] in
                    
                    self?.business = business
                    self?.name = business.name
                    self?.email = business.email ?? ""
                    self?.phone = business.phoneNumber ?? ""
                    self?.street = business.address?.street ?? ""
                    self?.street2 = business.address?.street2 ?? ""
                    self?.city = business.address?.city ?? ""
                    self?.selectedState = Constants.USState(rawValue: business.address?.state ?? "")
                    self?.zip = business.address?.zip ?? ""
                    self?.selectedCategories = business.categories.compactMap({ BusinessCategory(rawValue: $0) })
                    self?.selectedSubcategories = business.subcategories.compactMap({ BusinessSubcategory(rawValue: $0) })
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("business details"),
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
    
    func createOrUpdate() {
        
        if self.isCreateContext {
            create()
        } else {
            update()
        }
        
    }
    
    private func create() {
        
        guard let authUser = self.authService.currentUser else { return }
        
        if !self.email.isValidEmail() {
            
            self.alertService
                .showAlert(Constants.INVALID_EMAIL_ALERT())
            
            return
            
        }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let newBusiness = Business(
                    id: UUID().uuidString,
                    name: self.name,
                    description: "",
                    email: self.email,
                    phoneNumber: self.phone,
                    address: .init(
                        street: self.street,
                        street2: self.street2.isEmpty ? nil : self.street2,
                        city: self.city,
                        state: self.selectedState?.rawValue ?? Constants.USState.CA.rawValue,
                        zip: self.zip
                    ),
                    owner: authUser,
                    categories: self.selectedCategories.map { $0.rawValue },
                    subcategories: self.selectedSubcategories.map { $0.rawValue },
                    employees: [],
                    locations: [],
                    employeeInvites: []
                )
                
                _ = try await self.apiService
                    .createBusiness(business: newBusiness)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Business created successfully.",
                        action: {
                            self.navigationService?.popWithDelay()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "business"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    private func update() {
        
        guard let businessId else { return }
        
        if !self.email.isValidEmail() {
            
            self.alertService
                .showAlert(Constants.INVALID_EMAIL_ALERT())
            
            return
            
        }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let updatedBusiness = Business(
                    id: businessId,
                    name: self.name,
                    description: "",
                    email: self.email,
                    phoneNumber: self.phone,
                    address: .init(
                        street: self.street,
                        street2: self.street2.isEmpty ? nil : self.street2,
                        city: self.city,
                        state: self.selectedState?.rawValue ?? Constants.USState.CA.rawValue,
                        zip: self.zip
                    ),
                    owner: self.business?.owner ?? .DUMMY_DATA(),
                    categories: self.selectedCategories.map { $0.rawValue },
                    subcategories: self.selectedSubcategories.map { $0.rawValue },
                    employees: [],
                    locations: [],
                    employeeInvites: []
                )
                
                try await self.apiService
                    .updateBusiness(business: updatedBusiness)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Business updated successfully.",
                        action: {
                            self.navigationService?.popWithDelay()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while updating your business. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    func set(category: BusinessCategory) {
        
        if self.selectedCategories.contains(category) {
            
            // Remove the category
            self.selectedCategories.removeAll { $0 == category }
            
            // Also remove all subcategories that belong to this category
            self.selectedSubcategories.removeAll { $0.category == category }
            
        } else {
            self.selectedCategories.append(category)
        }
        
    }
    
    func set(subcategory: BusinessSubcategory) {
        
        if self.selectedSubcategories.contains(subcategory) {
            self.selectedSubcategories.removeAll { $0 == subcategory }
        } else {
            self.selectedSubcategories.append(subcategory)
        }
        
    }
    
    func set(state: Constants.USState?) {
        self.selectedState = state
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension BusinessCreateEditViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessCreateEdit(businessId: self.businessId)))
    }
    
}

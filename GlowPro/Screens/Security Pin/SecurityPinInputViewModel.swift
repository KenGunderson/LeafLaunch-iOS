//
//  SecurityPinInput.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/15/25.
//

import Foundation

final class SecurityPinInputViewModel: ViewModel {
    
    internal let loggerName: String = "SECURITY_PIN_INPUT_VIEW_MODEL"
    internal let loggerEmoji: String = "👮🏻‍♂️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    @Published var pinText: String = ""
    @Published private(set) var shouldDismiss: Bool = false
    
    private var currentPin = ""
    
    var isContinueButtonEnabled: Bool {
        return true
    }

    private var businessId: String!
    private var completion: ((Bool) -> Void)?
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.activeDestinationService = activeDestinationService
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
               completion: ((Bool) -> Void)?) -> Self {
        
        self.businessId = businessId
        self.completion = completion
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        let pin = self.userDefaultsService.getSecurityPinForBusinessId(self.businessId)

        if let pin  {
            self.currentPin = pin
        } else {
            
            self.alertService.showAlert(.init(
                .appAlert(
                    .error(
                        message: "There is no pin set on this account; please contact support for assistance.",
                        action: {})
                ))
            )
            
        }
        
    }
    
    func handleContinue() {
        
        guard self.pinText == self.currentPin else {
            
            self.alertService.showAlert(.init(
                .appAlert(
                    .error(
                        title: "Incorrect Pin",
                        message: "The pin you entered is incorrect. Please try again.",
                        action: {})
                ))
            )
            
            return
            
        }
        
        self.completion?(true)
        self.shouldDismiss = true
        
    }
    
    private func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension SecurityPinInputViewModel {
    
    func track() {
        self.analyticsService.track(screen: .business(.businessSecurityPinInput(businessId: self.businessId)))
    }
    
}

//
//  SubscriptionManageViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/15/25.
//

import Foundation
import SwiftUI

final class SubscriptionManageViewModel: ViewModel {
    
    internal let loggerName: String = "SUBSCRIPTION_MANAGE_VIEW_MODEL"
    internal let loggerEmoji: String = "👮🏻‍♂️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let stripeService: StripeServiceProtocol

    @Published private(set) var business: Business?
    
    @Published private(set) var shouldDismiss: Bool = false
    @Published var shouldPresentCancelSubscriptionSheet: Bool = false
    
    @Published private(set) var isLoading: Bool = false
        
    var businessId: String!
        
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         stripeService: StripeServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.activeDestinationService = activeDestinationService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        self.stripeService = stripeService
        
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
                
                await MainActor.run {
                    self.business = business
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("subscription"),
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
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .subscriptionManage)
            .receiveOnMain()
            .sink { [weak self] in
                
                self?.loadData()
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    func unsubscribe() {
        
        guard let business = self.business else { return }
        guard let subscription = business.stripeSubscription else { return }
        
        Task {
            
            do {
                
                try await self.apiService
                    .unsubscribe(subscriptionId: subscription.stripeSubscriptionId)
                
            } catch {
                
                presentErrorAlert(error: error)
                self.logger.error("\(error.getMessageForError())")
                
            }
            
            loadData()
            
        }
        
    }
    
    func resubscribe() {
        
        guard let business = self.business else { return }
        guard let subscription = business.stripeSubscription else { return }
        
        Task {
            
            do {
                
                try await self.apiService
                    .resubscribe(subscriptionId: subscription.stripeSubscriptionId)
                
            } catch {
                
                presentErrorAlert(error: error)
                self.logger.error("\(error.getMessageForError())")
                
            }
            
            loadData()
            
        }
        
    }
    
    func upgradeOrDowngrade(priceId: String) {
        
        guard let business = self.business else { return }
        guard let subscription = business.stripeSubscription else { return }
        
        Task {
            
            do {
                
                try await self.apiService.upgradeOrDowngradeSubscription(
                    subscriptionId: subscription.stripeSubscriptionId,
                    priceId: priceId
                )
                
            } catch {
                
                presentErrorAlert(error: error)
                self.logger.error("\(error.getMessageForError())")
                
            }
            
            loadData()
            
        }
        
    }
    
    private func presentErrorAlert(error: Error) {
        
        self.alertService
            .showAlert(.init(.appAlert(.error(
                message: error.getMessageForError(),
                action: {}
            ))))
        
    }
    
    func getNextBillingDate() -> String {
        
        let calendar = Calendar.current
        let now = Date()
        
        // 1. Add one month
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) else {
            return ""
        }
        
        // 2. Get the first day of that month
        let components = calendar.dateComponents([.year, .month], from: nextMonth)
        guard let firstDay = calendar.date(from: components) else {
            return ""
        }
        
        // 3. Format however you want
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"   // “January 1, 2026”
        
        return formatter.string(from: firstDay)
        
    }
    
}

extension SubscriptionManageViewModel {
    
    func track() {
        self.analyticsService.track(screen: .subscription(.manageSubscription))
    }
    
}

//
//  SubscriptionPaywallViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import Foundation
import SwiftUI

final class SubscriptionPaywallViewModel: ViewModel {
    
    enum Context: Equatable {
        
        case view
        case create
        case update(subscriptionId: String,
                    selectedProduct: StripeSubscriptionProduct,
                    selectedInterval: Interval)
        
    }
    
    enum Interval: String, Selectable, CaseIterable {
        
        var id: String { return self.rawValue }
        
        case monthly
        case yearly
        
        var description: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
        
        var stripeName: String {
            switch self {
            case .monthly: return "month"
            case .yearly: return "year"
            }
        }
        
    }
    
    internal let loggerName: String = "PAYWALL_VIEW_MODEL"
    internal let loggerEmoji: String = "👮🏻‍♂️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let stripeService: StripeServiceProtocol

    @Published private(set) var shouldDismiss: Bool = false
    
    @Published private(set) var paywallItem: SubscriptionPaywallItem!
    @Published private(set) var extractedColors: [Color] = []
    
    @Published private(set) var products: [StripeSubscriptionProduct] = []
    @Published var selectedInterval: Interval? = .monthly
    
    @Published private(set) var selectedProduct: StripeSubscriptionProduct?
    @Published private(set) var isLoading: Bool = false
    
    @Published var shouldShowSubscriptionSuccessAlert: Bool = false
    
    var businessId: String {
        return self.activeDestinationService.businessId ?? ""
    }
    
    var isSubscribeButtonEnabled: Bool {
        
        let isValid = self.selectedProduct != nil
        
        switch self.context! {
        case .view: return false
        case .create: return isValid
        case .update(_, let currentProduct, _):
            
            return isValid && (currentProduct != self.selectedProduct)
            
        }
        
    }
        
    private(set) var context: Context!
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
    func setup(context: Context,
               paywallItem: SubscriptionPaywallItem) -> Self {
        
        self.context = context
        self.paywallItem = paywallItem
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func set(product: StripeSubscriptionProduct?) {
        
        if self.selectedProduct != product {
            self.selectedProduct = product
        } else {
            self.selectedProduct = nil
        }
        
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        extractColor()
        
        Task {
            
            do {
                
                let products = try await self.apiService
                    .getAllSubscriptionProducts()
                
                let sortedProducts = products
                    .sorted(by: { ($0.metadata?.totalNumberOfMedia ?? 0) < ($1.metadata?.totalNumberOfMedia ?? 0) })
                
                await MainActor.run {
                    
                    self.products = sortedProducts
                    
                    switch self.context! {
                    case .view: break
                    case .create: break
                    case .update(_, let selectedProduct, let selectedInterval):
                        
                        self.selectedProduct = selectedProduct
                        self.selectedInterval = selectedInterval
                        
                    }
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("subscription products"),
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
    
    @MainActor
    func handleSubscribe() {
        
        switch self.context! {
        case .view: return
        case .create: subscribe()
        case .update(let subscriptionId, let selectedProduct, let selectedInterval):
            
            upgradeOrDowngrade(
                subscriptionId: subscriptionId,
                currentProduct: selectedProduct,
                currentInterval: selectedInterval
            )
            
        }
        
    }
    
    private func upgradeOrDowngrade(subscriptionId: String,
                                    currentProduct: StripeSubscriptionProduct,
                                    currentInterval: Interval) {
        
        let selectedIntervalName = self.selectedInterval?.stripeName ?? Interval.monthly.stripeName
        
        guard let product = self.selectedProduct else { return }
        guard let filteredPrice = product.prices.first(where: { $0.interval == selectedIntervalName && $0.amount > 0 }) else { return }
        
        Task {
            
            do {
                
                try await self.apiService.upgradeOrDowngradeSubscription(
                    subscriptionId: subscriptionId,
                    priceId: filteredPrice.id
                )
                
                await MainActor.run {
                    
                    self.shouldDismiss = true
                    self.viewLifecycleService.reload(for: [.businessHome, .subscriptionManage])
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    self.navigationService?
                        .modal(fullScreenCover: .subscriptionManage(businessId: self.businessId))
                    
                }
                
            } catch {
                
                self.alertService.showAlert(.init(.appAlert(.error(
                    message: error.getMessageForError(),
                    action: {}
                ))))
                
                self.logger.error("\(error.getMessageForError())")
                
            }
            
            loadData()
            
        }
        
    }
    
    @MainActor
    private func subscribe() {
        
        let selectedIntervalName = self.selectedInterval?.stripeName ?? Interval.monthly.stripeName
        
        guard let product = self.selectedProduct else { return }
        guard let filteredPrice = product.prices.first(where: { $0.interval == selectedIntervalName && $0.amount > 0 }) else { return }
        guard let viewController = UIApplication.shared.topMostViewController else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let businessId = self.businessId
                
                // Setup Customer
                
                try await self.stripeService
                    .setupCustomer(businessId: businessId)
                
                // Present Subscription Sheet
                
                let _ = await self.stripeService.presentSubscriptionSheet(
                    priceId: filteredPrice.id,
                    from: viewController
                )

                // Subscribe
                
                let sub = try await self.apiService.subscribe(
                    businessId: businessId,
                    productId: product.id,
                    priceId: filteredPrice.id,
                    setupIntentId: self.stripeService.currentSetupIntentId ?? ""
                )
                
                self.logger.debug("Created subscription: \(sub.id)")
                
                await MainActor.run {
                    
                    self.shouldShowSubscriptionSuccessAlert = true
                    self.viewLifecycleService.reload(for: [.businessHome, .subscriptionManage])
                    
                }
                
            } catch {
                
                self.alertService.showAlert(.init(.appAlert(.error(
                    message: error.getMessageForError(),
                    action: {}
                ))))
                
            }
            
            self.alertService
                .dismissLoadingIndicator()

        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
    private func extractColor() {
        
        Task(priority: .userInitiated) {
            
            do {
                
                switch self.paywallItem.illustration {
                case .image(let image, _):
                    
                    let image = UIImage(resource: image)
                    
                    let uiColors = try image.extractColors(
                        numberOfColors: 2,
                        sortByProminence: true
                    )
                    
                    let swiftUIColors = uiColors.map { Color($0) }
                    
                    await MainActor.run { [weak self] in
                        self?.extractedColors = swiftUIColors
                    }
                    
                default: break
                }
                
            } catch {
                print("Failed to extract colors:", error)
            }
            
        }
        
    }
    
}

extension SubscriptionPaywallViewModel {
    
    func track() {
        self.analyticsService.track(screen: .subscription(.paywall))
    }
    
}

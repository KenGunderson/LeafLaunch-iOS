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
        case update(stripeSubscriptionId: String,
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
        
        static func createFromStripeName(_ name: String) -> Self {
            
            var interval: String {
                
                if name == "month" { return "monthly"}
                else if name == "year" { return "yearly" }
                return "monthly"
                
            }
            
            return .init(rawValue: interval)!
            
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
        let isFreemiumSelected = self.selectedProduct?.prices.contains(where: { $0.interval == "freemium"}) ?? false
        
        switch self.context! {
        case .view: return false
        case .create: return isValid && !isFreemiumSelected
        case .update(_, let currentProduct, let currentInterval):
            
            let isSameSelection = (currentProduct == self.selectedProduct && (currentInterval == self.selectedInterval))
            return isValid && !isSameSelection
            
        }
        
    }
        
    private(set) var context: Context!
    private(set) var completion: (() -> Void)?
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
               paywallItem: SubscriptionPaywallItem,
               completion: (() -> Void)? = nil) -> Self {
        
        self.context = context
        self.paywallItem = paywallItem
        self.completion = completion
        
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
                
                var sortedProducts = products
                    .sorted(by: { ($0.metadata?.totalNumberOfMedia ?? 0) < ($1.metadata?.totalNumberOfMedia ?? 0) })
                
                if self.context != .create {
                    
                    sortedProducts = sortedProducts.filter { product in
                        product.prices.contains { $0.interval == "freemium" }
                    }
                    
                }
                
                await MainActor.run { [sortedProducts] in
                    
                    self.products = sortedProducts
                    
                    switch self.context! {
                    case .view: break
                    case .create:
                        
                        self.selectedProduct = sortedProducts.first { product in
                            product.prices.contains { $0.interval == "freemium" }
                        }
                        
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
        
        switch self.context! {
        case .update(_,
                     let selectedProduct,
                     let selectedInterval):
            
            let currentPrice = selectedProduct.prices.first(where: { $0.interval == selectedInterval.stripeName && $0.amount > 0 })?.amount ?? 0
            
            if currentPrice > filteredPrice.amount {
                
                if canDowngrade() {
                    break
                } else {
                    
                    self.alertService.showAlert(.init(.appAlert(.error(
                        title: "Almost There!",
                        message: "To move to a smaller plan, your account needs to fit within that plan’s limits. Please remove any extra locations or team members you no longer need, then try downgrading again.",
                        action: { }
                    ))))
                    
                    return
                    
                }
                
            }
            
        case .create: return
        case .view: return
        }
        
        Task {
            
            do {
                
                try await self.apiService.upgradeOrDowngradeSubscription(
                    subscriptionId: subscriptionId,
                    priceId: filteredPrice.id
                )
                
                await MainActor.run {
                    
                    self.viewLifecycleService.reload(for: [.businessHome, .subscriptionManage])
                    self.shouldDismiss = true
                    
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
    
    private func canDowngrade() -> Bool {
        
        guard let business = self.activeDestinationService.business else { return false }
        guard let selectedProduct = self.selectedProduct else { return false }
        
        switch self.context! {
        case .update:
            
            let totalNumberOfLocations = business.totalLocationCount
            let totalNumberOfEmployees = business.totalEmployeeCount
            
            let proposedNumberOfLocations = selectedProduct.metadata?.totalNumberOfLocations ?? 0
            let proposedNumberOfEmployees = selectedProduct.metadata?.totalNumberOfEmployees ?? 0
            
            let canDowngradeLocations = totalNumberOfLocations <= proposedNumberOfLocations
            let canDowngradeEmployees = totalNumberOfEmployees <= proposedNumberOfEmployees
            
            return (canDowngradeLocations && canDowngradeEmployees)
            
        case .create: return true
        case .view: return true
        }
        
    }
    
}

extension SubscriptionPaywallViewModel {
    
    func track() {
        self.analyticsService.track(screen: .subscription(.paywall))
    }
    
}

//
//  SubscriptionPaywallViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import Foundation
import SwiftUI

final class SubscriptionPaywallViewModel: ViewModel {
    
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
        return self.selectedProduct != nil
    }
        
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         stripeService: StripeServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.activeDestinationService = activeDestinationService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.stripeService = stripeService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(paywallItem: SubscriptionPaywallItem) -> Self {
        
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
    func subscribe() {
        
        let selectedIntervalName = self.selectedInterval?.stripeName ?? Interval.monthly.stripeName
        
        guard let product = self.selectedProduct else { return }
        guard let filteredPrice = product.prices.first(where: { $0.interval == selectedIntervalName }) else { return }
        guard let defaultPriceId = product.defaultPriceId else { return }
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

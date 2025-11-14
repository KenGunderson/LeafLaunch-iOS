//
//  StripeService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/14/25.
//

import UIKit
import StripeCore
import StripePaymentSheet

final class StripeService: StripeServiceProtocol {
    
    internal let loggerName: String = "STRIPE_SERVICE"
    internal let loggerEmoji: String = "💳"
    
    private let apiService: APIServiceProtocol
    
    private var customerConfig: PaymentSheet.CustomerConfiguration?
    private var paymentSheet: PaymentSheet?
    
    private(set) var currentSetupIntentId: String?
    
    init(apiService: APIServiceProtocol) {
        
        self.apiService = apiService
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setupCustomer(businessId: String) async throws {
        
        let result = try await self.apiService
            .getStripePaymentLink(businessId: businessId)
        
        STPAPIClient.shared.publishableKey = result.publishableKey
        
        self.customerConfig = .init(
            id: result.customerId,
            ephemeralKeySecret: result.ephemeralKeySecret
        )
        
        self.currentSetupIntentId = result.setupIntentId
        
        var configuration = PaymentSheet.Configuration()
        configuration.customer = self.customerConfig
        configuration.merchantDisplayName = "GlowPro"
        
        self.paymentSheet = PaymentSheet(
            setupIntentClientSecret: result.setupIntentCustomerSecret,
            configuration: configuration
        )
        
        self.logger.debug(
            """
            Customer + PaymentSheet Setup:
            BUSINESS_ID: \(businessId)
            CUSTOMER_ID: \(result.customerId)
            SETUP_INTENT_ID: \(result.setupIntentId)
            """
        )
        
    }
    
    func presentSubscriptionSheet(priceId: String,
                                  from viewController: UIViewController) async -> PaymentSheetResult? {
        
        guard let paymentSheet else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            
            paymentSheet.present(from: viewController) { result in
                continuation.resume(returning: result)
            }
            
        }
                    
    }
    
    func logout() {
        
        STPAPIClient.shared.publishableKey = nil
        
        self.customerConfig = nil
        self.paymentSheet = nil
        self.currentSetupIntentId = nil
        
    }
    
}

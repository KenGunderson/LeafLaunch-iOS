//
//  StripeServiceProtocol.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/14/25.
//

import UIKit
import StripePaymentSheet

protocol StripeServiceProtocol: Loggable {
    
    var currentSetupIntentId: String? { get }
        
    func setupCustomer(businessId: String) async throws
    
    func presentSubscriptionSheet(priceId: String,
                                  from viewController: UIViewController) async -> PaymentSheetResult?
    
    func logout()
    
    
}

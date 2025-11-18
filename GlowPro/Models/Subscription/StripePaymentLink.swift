//
//  StripePaymentLink.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/17/25.
//

import Foundation

struct StripePaymentLink: Codable {
    
    let setupIntentId: String
    let setupIntentCustomerSecret: String
    let ephemeralKeySecret: String
    let customerId: String
    let publishableKey: String
    
    private enum CodingKeys: String, CodingKey {
        
        case setupIntentId = "setup_intent_id"
        case setupIntentCustomerSecret = "setup_intent_customer_secret"
        case ephemeralKeySecret = "ephemeral_key_secret"
        case customerId = "customer_id"
        case publishableKey = "publishable_key"
        
    }
    
}

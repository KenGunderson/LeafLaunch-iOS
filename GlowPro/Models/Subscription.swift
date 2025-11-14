//
//  Subscription.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/13/25.
//

import Foundation

enum StripeSubscriptionStatus: String, Codable {
    
    case active = "ACTIVE"
    case cancelled = "CANCELLED"
    case incomplete = "INCOMPLETE"
    case incompleteExpired = "INCOMPLETE_EXPIRED"
    case pastDue = "PAST_DUE"
    case paused = "PAUSED"
    case trailing = "TRIALING"
    case unpaid = "UNPAID"
    
}

struct StripeSubscription: Identifiable, Codable {
    
    let id: String
    let businessId: String
    let customerId: String
    let stripeSubscriptionId: String
    let stripeProductId: String
    let status: StripeSubscriptionStatus
    let deleted: Bool
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case customerId = "customer_id"
        case stripeSubscriptionId = "stripe_subscription_id"
        case stripeProductId = "stripe_product_id"
        case status
        case deleted
        
    }
    
}

struct StripeSubscriptionProduct: Identifiable, Codable, Hashable {
    
    struct Metadata: Hashable, Codable {
        
        let totalNumberOfEmployees: Int?
        let totalNumberOfLocations: Int?
        let totalNumberOfMedia: Int?
        
        
        private enum CodingKeys: String, CodingKey {
            
            case totalNumberOfEmployees = "total_number_of_employees"
            case totalNumberOfLocations = "total_number_of_locations"
            case totalNumberOfMedia = "total_number_of_media"
            
        }
        
    }
  
    let id: String
    let name: String
    let description: String?
    let defaultPriceId: String?
    let price: Int
    let active: Bool
    let metadata: Metadata?
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case description
        case defaultPriceId = "default_price_id"
        case price
        case active
        case metadata
        
    }
    
}

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

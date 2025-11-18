//
//  Subscription.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/13/25.
//

import Foundation

enum StripeSubscriptionStatus: String, Codable, Hashable {
    
    case active = "ACTIVE"
    case cancelled = "CANCELLED"
    case incomplete = "INCOMPLETE"
    case incompleteExpired = "INCOMPLETE_EXPIRED"
    case pastDue = "PAST_DUE"
    case paused = "PAUSED"
    case trailing = "TRIALING"
    case unpaid = "UNPAID"
    
}

struct StripeSubscription: Identifiable, Codable, Hashable {
    
    let id: String
    let businessId: String
    let customerId: String
    let stripeSubscriptionId: String
    let stripeProductId: String
    let stripeInterval: String
    let status: StripeSubscriptionStatus
    let deleted: Bool
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case customerId = "customer_id"
        case stripeSubscriptionId = "stripe_subscription_id"
        case stripeProductId = "stripe_product_id"
        case stripeInterval = "stripe_interval"
        case status
        case deleted
        
    }
    
}

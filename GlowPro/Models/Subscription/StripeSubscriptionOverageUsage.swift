//
//  StripeSubscriptionOverageUsage.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/17/25.
//

import Foundation

struct StripeSubscriptionOverageUsage: Codable, Hashable {
    
    let mediaAllowed: Int
    let mediaUsed: Int
    let mediaUsagePercentage: Double
    let mediaRemaining: Int
    let isLimitReached: Bool
    
    private enum CodingKeys: String, CodingKey {
        
        case mediaAllowed = "media_allowed"
        case mediaUsed = "media_used"
        case mediaUsagePercentage = "media_usage_percentage"
        case mediaRemaining = "media_remaining"
        case isLimitReached = "is_limit_reached"
        
    }
    
    init(mediaAllowed: Int = 0,
         mediaUsed: Int = 0,
         mediaUsagePercentage: Double = 0,
         mediaRemaining: Int = 0,
         isLimitReached: Bool = false) {
        
        self.mediaAllowed = mediaAllowed
        self.mediaUsed = mediaUsed
        self.mediaUsagePercentage = mediaUsagePercentage
        self.mediaRemaining = mediaRemaining
        self.isLimitReached = isLimitReached
        
    }
    
}

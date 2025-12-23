//
//  SubscriptionPaywallItem.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/24/25.
//

import Foundation

struct SubscriptionPaywallItem {
    
    let id: String
    let title: String
    let description: String
    let tagline: String
    let price: Double
    let illustration: ImageSource
    
}

@MainActor
extension SubscriptionPaywallItem {
    
    static let GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION = SubscriptionPaywallItem(
        id: "glowpro_premium_monthly_subscription",
        title: "Premium Access",
        description: "Level up your workflow with advanced tools, secure storage, and team collaboration.",
        tagline: "Capture. Organize. Grow.",
        price: 29.99,
        illustration: .image(.illustrationWelcome)
    )

    static let GLOWPRO_ADD_LOCATION_MONTHLY = SubscriptionPaywallItem(
        id: "glowpro_add_location_monthly",
        title: "Add Additional Location",
        description: "Expand your workspace with a new location and keep everything neatly separated.",
        tagline: "Grow your practice the right way.",
        price: 19.99,
        illustration: .image(.illustrationStorefront)
    )
    
}

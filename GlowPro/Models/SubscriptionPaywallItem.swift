//
//  SubscriptionPaywallItem.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/24/25.
//

import Foundation

struct SubscriptionPaywallItem {
    
    struct BenefitItem {
        
        let title: String
        let message: String
        let icon: ImageSource
        
    }
    
    let id: String
    let title: String
    let description: String
    let tagline: String
    let price: Double
    let illustration: ImageSource
    let benefits: [BenefitItem]
    
}

@MainActor
extension SubscriptionPaywallItem {
    
    static let GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION = SubscriptionPaywallItem(
        id: "glowpro_premium_monthly_subscription",
        title: "Premium Access",
        description: "Level up your workflow with advanced tools, secure storage, and team collaboration.",
        tagline: "Capture. Organize. Grow.",
        price: 29.99,
        illustration: .image(.illustrationWelcome, renderingMode: .original),
        benefits: [
            
            .init(
                title: "1,500 Images Per Month",
                message: "Capture up to 1,500 high-quality images every month without interruption.",
                icon: .systemImage("camera.on.rectangle")
            ),
            .init(
                title: "Unlimited Team Invites",
                message: "Invite your entire staff to collaborate with full access included.",
                icon: .systemImage("person.3.fill")
            ),
            .init(
                title: "Custom Security Settings",
                message: "Control access, roles, and visibility with advanced security configuration.",
                icon: .systemImage("shield.lefthalf.fill")
            ),
            .init(
                title: "HIPAA-Compliant Storage",
                message: "Your media is stored using HIPAA-compliant infrastructure and safeguards.",
                icon: .systemImage("lock.shield.fill")
            ),
            .init(
                title: "Priority Support",
                message: "Get priority access to our support team whenever you need help.",
                icon: .systemImage("bolt.circle.fill")
            )
        ]
        
    )

    static let GLOWPRO_ADD_LOCATION_MONTHLY = SubscriptionPaywallItem(
        id: "glowpro_add_location_monthly",
        title: "Add Additional Location",
        description: "Expand your workspace with a new location and keep everything neatly separated.",
        tagline: "Grow your practice the right way.",
        price: 19.99,
        illustration: .image(.illustrationStorefront, renderingMode: .original),
        benefits: [

            .init(
                title: "Separate & Categorized Data",
                message: "Keep photos, notes, and staff data neatly separated by location for clearer organization.",
                icon: .systemImage("folder.badge.gearshape")
            ),

            .init(
                title: "1,500 Additional Photos",
                message: "Gain 1,500 extra monthly photos specifically for this added location.",
                icon: .systemImage("camera.on.rectangle")
            ),

            .init(
                title: "Dedicated Location Analytics",
                message: "Track performance, usage, and activity at this location with its own dedicated insights.",
                icon: .systemImage("chart.xyaxis.line")
            )
        ]
    )
    
}

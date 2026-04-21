//
//  SubscriptionProduct.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/21/26.
//

import Foundation

struct SubscriptionProduct: Identifiable, Codable, Equatable, Sendable {
    
    let id: String
    let title: String
    let description: String
    let price: Decimal
    let displayPrice: String
    
}

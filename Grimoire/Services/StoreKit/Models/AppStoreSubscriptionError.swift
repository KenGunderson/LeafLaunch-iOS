//
//  AppStoreSubscriptionError.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/21/26.
//

import Foundation

enum AppStoreSubscriptionError: LocalizedError, Sendable {
    
    case productIdentifiersMissing
    case productNotFound(productId: String)
    case userCancelled
    case purchasePending
    case unknownPurchaseResult
    case failedVerification
    
    var errorDescription: String? {
        
        switch self {
        case .productIdentifiersMissing: return "Missing StoreKit product identifiers."
        case .productNotFound(let productId): return "Product not found for id: \(productId)."
        case .userCancelled: return "User cancelled purchase."
        case .purchasePending: return "Purchase is pending approval."
        case .unknownPurchaseResult: return "Unknown purchase result."
        case .failedVerification: return "Failed to verify the transaction."
        }
        
    }
    
}

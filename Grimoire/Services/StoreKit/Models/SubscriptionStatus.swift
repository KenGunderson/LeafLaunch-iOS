//
//  SubscriptionStatus.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/21/26.
//

import Foundation

enum SubscriptionStatus: Equatable, Sendable {
    
    case active(productId: String, expiryDate: Date?)
    case expired(expiryDate: Date?)
    case none
    
    var isActive: Bool {
        
        if case .active = self {
            return true
        }
        
        return false
        
    }
    
    var expiryDate: Date? {
        
        switch self {
        case .active(_, let expiryDate): return expiryDate
        case .expired(let expiryDate): return expiryDate
        case .none: return nil
        }
        
    }
    
}

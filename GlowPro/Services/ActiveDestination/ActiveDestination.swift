//
//  ActiveDestination.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/25.
//

enum ActiveDestination: Sendable {
    
    case business(businessId: String)
    case location(locationId: String)
    
    var isBusiness: Bool {
        switch self {
        case .business: return true
        case .location: return false
        }
    }
    
    var isLocation: Bool {
        switch self {
        case .business: return false
        case .location: return true
        }
    }
    
    var destinationId: String {
        switch self {
        case .business(let businessId): return businessId
        case .location(let locationId): return locationId
        }
    }
    
}

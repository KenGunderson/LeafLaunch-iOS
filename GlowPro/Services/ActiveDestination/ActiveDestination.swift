//
//  ActiveDestination.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/25.
//

enum ActiveDestination: Sendable {
    
    case business(businessId: String, business: Business)
    
    case location(locationId: String,
                  location: Location,
                  locationEmployee: LocationEmployee,
                  business: Business)
    
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
        case .business(let businessId, _): return businessId
        case .location(let locationId, _, _, _): return locationId
        }
    }
    
    var prettyLog: String {
        switch self {
        case .business(let businessId, _): return "Business: \(businessId)"
        case .location(let locationId, _, _, _): return "Location: \(locationId)"
        }
    }
    
}

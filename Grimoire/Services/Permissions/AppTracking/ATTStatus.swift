//
//  ATTStatus.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/17/24.
//

import AppTrackingTransparency

enum ATTStatus {
    
    case notDetermined
    case restricted
    case denied
    case authorized
    
    var displayName: String {
        
        switch self {
        case .notDetermined: return "not determined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        }
        
    }
    
    var authorizationStatus: ATTrackingManager.AuthorizationStatus {
        
        switch self {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        }
        
    }

    static func fromAuthorizationStatus(_ status: ATTrackingManager.AuthorizationStatus) -> Self {
        
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        @unknown default: return .notDetermined
        }
        
    }
    
}

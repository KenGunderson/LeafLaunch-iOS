//
//  CameraError.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import Foundation

public enum CameraError: Error, AppCustomError {
        
    case permissionDenied
    case deviceUnavailable
    case inputAddFailed
    case outputAddFailed
    case imageCreationFailed
    
    var message: String {
        
        switch self {
        case .permissionDenied: return "Camera permission denied."
        case .deviceUnavailable: return "Back camera unavailable."
        case .inputAddFailed: return "Could not add camera input."
        case .outputAddFailed: return "Could not add photo output."
        case .imageCreationFailed: return "Failed to create image."
        }
        
    }
    
}

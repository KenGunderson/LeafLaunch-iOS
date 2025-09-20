//
//  FlashMode.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/19/25.
//

import Foundation
import AVFoundation

public enum CameraFlashMode: CaseIterable {
    
    case off
    case on
    case auto
    
    var displayName: String {
        switch self {
        case .off: return "Off"
        case .on: return "On"
        case .auto: return "Auto"
        }
    }
  
    var icon: String {
        switch self {
        case .off: return "bolt.slash"
        case .on: return "bolt.fill"
        case .auto: return "bolt.badge.automatic.fill"
        }
    }
          
    var captureDeviceMode: AVCaptureDevice.FlashMode {
        switch self {
        case .off: return .off
        case .on: return .on
        case .auto: return .auto
        }
    }
    
}

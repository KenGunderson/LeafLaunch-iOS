//
//  Ext+OSLogType.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/17/24.
//

import OSLog
import SwiftUI

extension OSLogType {
    
    static func allOptions() -> [String] {
        return [
            "Default",
            "Info",
            "Debug",
            "Error",
            "Fault"
        ]
    }
    
    func displayName() -> String {
        
        switch self {
        case .default: return "Default"
        case .info: return "Info"
        case .debug: return "Debug"
        case .error: return "Error"
        case .fault: return "Fault"
        default: return "Unknown"
        }
        
    }
    
    func color() -> Color {
        
        switch self {
        case .default: return .black
        case .info: return .blue
        case .debug: return .green
        case .error: return .red
        case .fault: return .orange
        default: return .gray
        }
        
    }
    
    func systemImage() -> String {

        switch self {
        case .default: return "dot.circle"
        case .info: return "info.circle"
        case .debug: return "wrench.and.screwdriver"
        case .error: return "xmark.octagon"
        case .fault: return "exclamationmark.triangle"
        default: return "questionmark.circle"
        }
        
    }
    
}

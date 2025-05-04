//
//  EventType.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import Foundation

enum EventType {
    
    case app
    case screen
    case error
    
    var displayName: String {
        
        switch self {
        case .app: return "App"
        case .screen: return "Screen"
        case .error: return "Error"
        }
        
    }
    
    var apiName: String {
       
        switch self {
        case .app: return "app_event"
        case .screen: return "screen_event"
        case .error: return "error_event"
        }
        
    }

}

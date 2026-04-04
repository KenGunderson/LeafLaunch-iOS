//
//  NotificationPayloadRouter.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

struct NotificationPayloadRouter {
    
    func origin(for payload: [AnyHashable: Any]) -> NotificationPayloadOrigin {
        
        if let explicitOrigin = payload["notification_source"] as? String {
            return self.origin(from: explicitOrigin)
        }
        
        if let explicitType = payload["payload_type"] as? String {
            return self.origin(from: explicitType)
        }
        
        if let source = payload["source"] as? String,
           source == "local_notification_service" {
            return .local
        }
        
        if payload["aps"] != nil {
            return .remote
        }
        
        return .local
        
    }
    
    private func origin(from rawValue: String) -> NotificationPayloadOrigin {
        
        let normalized = rawValue
            .trimmed()
            .lowercased()
        
        switch normalized {
        case "local", "local_notification", "local_notification_service":
            return .local
        default:
            return .remote
        }
        
    }
    
}

//
//  PushNotification.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 9/12/23.
//

import UIKit
import UserNotifications

struct PushNotification {
    
    enum PushNotificationType: String {
        
        case test = "test"
        case invite = "invite"
        case accpetInvite = "accept-invite"
        case generic = "_generic"
        
    }

    enum Delivery: String {

        case launch
        case background
        case foreground

        static var current: Delivery {

            var state: UIApplication.State = .active

            if Thread.isMainThread {
                state = UIApplication.shared.applicationState
            }
            else {

                DispatchQueue.main.sync {
                    state = UIApplication.shared.applicationState
                }

            }

            if state == .background || state == .inactive {
                return .background
            }

            return .foreground

        }

    }

    var type: PushNotificationType
    var delivery: Delivery = Delivery.current

    var alert: [String: Any]?
    var info: [AnyHashable: Any]

    var isSilent: Bool {
        (self.alert == nil)
    }

    var alertPresentationOptions: UNNotificationPresentationOptions {

        switch self.delivery {
        case .foreground:

            switch self.type {
            case .generic: return [.sound]
            default: return [.banner, .sound]
            }

        default: return [.banner, .list, .sound, .badge]
        }

    }

    init(type: PushNotificationType,
         alert: [String: Any]?,
         info: [AnyHashable: Any]) {

        self.type = type
        self.alert = alert
        self.info = info

    }

}

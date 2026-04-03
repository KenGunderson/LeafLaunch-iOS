//
//  PushNotificationService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
@preconcurrency import UserNotifications
import UIKit

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate, PushNotificationServiceProtocol {

    internal let loggerName: String = "PUSH_NOTIFICATIONS_SERVICE"
    internal let loggerEmoji: String = "🔔"
    
    private var tabBarNavigationService: TabBarNavigationService?
    private let viewLifecycleService: ViewLifecycleServiceProtocol
        
    init(viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.viewLifecycleService = viewLifecycleService
        super.init()
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func parsePushNotification(_ pushNotification: UNNotification?,
                               isTapped: Bool) {
        
        guard let pushNotification else { return }
        
        self.log(message: "Parsing Push Notification: \(pushNotification.request.content)")
        
        guard let push = self.notification(from: pushNotification.request.content.userInfo) else { return }
        
        self.log(message: "Did Parse Push Notification \(push)")
        
        if isTapped {
            handleTestNotificationTapped(push)
        } else {
            handleNotificationReceived(push)
        }
        
    }
    
    private func notification(from payload: [AnyHashable: Any],
                              delivery: PushNotification.Delivery? = nil) -> PushNotification? {

        var type: PushNotification.PushNotificationType = .generic

        if let typeString = payload["type"] as? String,
           let notificationType = PushNotification.PushNotificationType(rawValue: typeString) {
            type = notificationType
        }

        var alert: [String: Any]?

        if let aps = payload["aps"] as? [String: Any] {

            if let _alert = aps["alert"] as? [String: Any] {
                alert = _alert
            } else if let _alert = aps["alert"] as? String {
                alert = ["body": _alert]
            }

        }

        var info = payload
        info["aps"] = nil
        info["title"] = nil
        info["body"] = nil

        var notification = PushNotification(
            type: type,
            alert: alert,
            info: info
        )

        if let delivery = delivery {
            notification.delivery = delivery
        }

        return notification
    }
    
    private func handleNotificationReceived(_ notification: PushNotification) {

        self.log(message: "push received: \(notification.type.rawValue)")
        handleNavigationForNotification(notification)
        
    }
    
    private func handleTestNotificationTapped(_ notification: PushNotification) {

        self.log(message: "push tapped: \(notification.type.rawValue)")
        handleNavigationForNotification(notification)
        
    }
    
    private func handleNavigationForNotification(_ notification: PushNotification) {
        
        switch notification.type {
        case .test:
            print("TEST PUSH") // call handle method to parse further and navigate to where you need
        case .generic:
            print("THIS IS A GENERIC PUSH")
        }
        
    }
    
}

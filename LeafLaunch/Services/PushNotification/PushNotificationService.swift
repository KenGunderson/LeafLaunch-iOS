//
//  PushNotificationService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
@preconcurrency import UserNotifications
import UIKit

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate, PushNotificationServiceProtocol {

    internal let loggerName: String = "PUSH_NOTIFICATIONS_SERVICE"
    internal let loggerEmoji: String = "🔔"
    
    private weak var navigationService: NavigationService?
    private let viewLifecycleService: ViewLifecycleServiceProtocol
        
    init(viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.viewLifecycleService = viewLifecycleService
        super.init()
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func parsePushNotification(_ pushNotification: UNNotification?,
                               isTapped: Bool) {
        
        guard let pushNotification else { return }
        
        guard pushNotification.request.trigger is UNPushNotificationTrigger else { return }

        parseRemoteNotification(pushNotification, isTapped: isTapped)
        
    }
    
    func parseRemoteNotification(_ pushNotification: UNNotification,
                                 isTapped: Bool) {
        
        self.log(message: "Parsing remote push notification: \(pushNotification.request.content)")
        
        guard let push = self.notification(from: pushNotification.request.content.userInfo) else { return }
        
        self.log(message: "Did parse remote push notification \(push)")
        
        if isTapped {
            self.handleRemoteNotificationTapped(push)
        }
        else {
            self.handleRemoteNotificationReceived(push)
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
    
    private func handleRemoteNotificationReceived(_ notification: PushNotification) {

        self.log(message: "remote push received: \(notification.type.rawValue)")
        self.handleNavigationForRemoteNotification(notification)
        
    }
    
    private func handleRemoteNotificationTapped(_ notification: PushNotification) {

        self.log(message: "remote push tapped: \(notification.type.rawValue)")
        self.handleNavigationForRemoteNotification(notification)
        
    }
    
    private func handleNavigationForRemoteNotification(_ notification: PushNotification) {
        
        switch notification.type {
        case .test: print("TEST PUSH")
        case .generic: print("THIS IS A GENERIC PUSH")
        }
        
    }

}

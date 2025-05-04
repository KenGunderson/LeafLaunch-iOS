//
//  PushNotificationService.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import UserNotifications
import UIKit

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate, PushNotificationServiceProtocol {
    
    private var tabBarNavigationService: TabBarNavigationService?
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private let logger = RuneLogger.service(.pushNotification)
    
    init(viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.viewLifecycleService = viewLifecycleService
        super.init()
        
        self.logger.logInit()
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func parsePushNotification(_ pushNotification: UNNotification?,
                               isTapped: Bool) {
        
        guard let pushNotification else { return }
        
        self.logger
            .debugMessage("Parsing Push Notification: \(pushNotification.request.content)")
        
        guard let push = self.notification(from: pushNotification.request.content.userInfo) else { return }
        
        self.logger
            .debugMessage("Did Parse Push Notification \(push)")
        
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

        self.logger.debugMessage("push received: \(notification.type.rawValue)")

        switch notification.type {
        case .test:
            print("TEST PUSH") // call handle method to parse further and navigate to where you need
        case .generic:
            print("THIS IS A GENERIC PUSH")
//        case .createChallenge: self.navigationService?.homeNavigationService.push(.createChallange)
//        case .challengeDetails:
//
//            if let challengeId = notification.info["challenge_id"] as? String {
//
//                self.navigationService?
//                    .homeNavigationService
//                    .push(.challengeDetails(.init(
//                        id: challengeId,
//                        challengeType: .calories,
//                        gameMode: .cooperative,
//                        title: "",
//                        goalAmount: 0,
//                        startDate: "",
//                        inviteCode: "",
//                        ownerId: "",
//                        createdAt: Date()
//                    )))
//
//            }
            
        }
        
//        self.viewLifecycleService?.triggerReload()
    }
    
    private func handleTestNotificationTapped(_ notification: PushNotification) {

        self.logger.debugMessage("push tapped: \(notification.type.rawValue)")

        // TODO: - Handle Deeplink Navigation
        // MARK: - THIS IS HOW WE PARSE
//        if let route = notification.info["deeplink"] as? String {
//        }
        
        // MARK: - Route them somewhere based on tap with navigationService
    }
}

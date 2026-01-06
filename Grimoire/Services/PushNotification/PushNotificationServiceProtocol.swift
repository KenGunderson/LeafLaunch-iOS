//
//  PushNotificationServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import UserNotifications
import Combine
import UIKit

protocol PushNotificationServiceProtocol: AnyObject, Loggable {
        
    func parsePushNotification(_ pushNotification: UNNotification?,
                               isTapped: Bool)
    
    func setup(tabBarNavigationService: TabBarNavigationService)
    
}

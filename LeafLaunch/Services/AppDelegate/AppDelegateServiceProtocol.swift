//
//  AppDelegateServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import UserNotifications
import UIKit

protocol DeviceTokenProviding: AnyObject {

    var deviceToken: String? { get }

}

protocol AppDelegateServiceProtocol: DeviceTokenProviding, Loggable {

    var deviceToken: String? { get }
    var deviceTokenPublisher: AnyPublisher<String?, Never> { get }

    var onNotificationPublisher: PassthroughSubject<UNNotification?, Never> { get }
    var onTappedNotificationPublisher: PassthroughSubject<UNNotification?, Never> { get }
    var appWillTerminatePublisher: PassthroughSubject<Void, Never> { get }

    func setup(appDelegate: AppDelegate)
    func clearNotification()

}

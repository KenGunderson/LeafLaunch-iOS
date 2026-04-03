//
//  LocalNotificationServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

import Foundation
import Combine
import UserNotifications

protocol LocalNotificationServiceProtocol: AnyObject, Loggable {
    
    var permissionGranted: Bool { get }
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> { get }
    
    var shouldPromptForPermissions: Bool { get }
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> { get }
    
    func refreshAuthorizationStatus()
    func requestPermissionIfNeeded()
    func requestPermission()
    
    func schedule(_ request: LocalNotificationScheduleRequest) async throws
    func decodeScheduledLocalNotification(from notification: UNNotification) -> LocalNotificationPayload?
    func remakeScheduledLocalNotificationIfNeeded(from notification: UNNotification) async
    
    func getPlannedNotifications() async -> [LocalNotificationSnapshotItem]
    func getIncomingNotifications() async -> [LocalNotificationSnapshotItem]
    
    func clearPlannedNotifications()
    func clearIncomingNotifications()
    func clearAllNotifications()
    
}

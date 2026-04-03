//
//  PushNotificationPermissionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import UserNotifications
import UIKit

final class PushNotificationPermissionService: PushNotificationPermissionServiceProtocol {
    
    internal let loggerName: String = "PUSH_NOTIFICATIONS_PERMISSION_SERVICE"
    internal let loggerEmoji: String = "🤚🏻"
    
    var permissionGranted: Bool {
        return self.localNotificationService.permissionGranted
    }
    
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> {
        return self.localNotificationService.permissionGrantedPublisher
    }
    
    var shouldPromptForPermissions: Bool {
        return self.localNotificationService.shouldPromptForPermissions
    }
    
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> {
        return self.localNotificationService.shouldPromptForPermissionsPublisher
    }
    
    private let localNotificationService: LocalNotificationServiceProtocol
    
    init(localNotificationService: LocalNotificationServiceProtocol) {
        
        self.localNotificationService = localNotificationService
        
        self.logInit()
        self.localNotificationService.refreshAuthorizationStatus()
        
    }
    
    
    deinit {
        self.logDeinit()
    }
    
    func requestPermissionIfNeeded() {
        
        self.log(message: "requestPermissionIfNeeded: \(self.shouldPromptForPermissions)")
        
        if self.shouldPromptForPermissions {
            requestPermission()
        }
        
    }
    
    func requestPermission() {
        
        self.log(message: "requestPermission")
        self.localNotificationService.requestPermission()
        
    }
    
}

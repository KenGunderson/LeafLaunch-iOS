//
//  AppDelegate.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import SwiftUI
import UIKit
import UserNotificationsUI
import Combine

class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate, Loggable {
    
    internal let loggerName: String = "APP_DELEGATE"
    internal let loggerEmoji: String = "🪈"
    
    private(set) var deviceTokenPublisher = PassthroughSubject<String, Never>()
    private(set) var pushNotificationPublisher = PassthroughSubject<UNNotification, Never>()
    private(set) var pushNotificationTappedPublisher = PassthroughSubject<UNNotification, Never>()
    private(set) var appWillTerminatePublisher = PassthroughSubject<Void, Never>()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UIApplication.shared.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setBadgeCount(0) { [weak self] error in
            
            if let error = error {
                
                self?.logError(
                    title: "App Delegate App Badge Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
        return true
        
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        self.deviceTokenPublisher.send(token)
        self.log(message: "DEVICE TOKEN: \(token)")
        
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        self.logError(
            title: "Did Fail To Register For Remote Notifications",
            message: error.getMessageForError()
        )
        
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        self.log(
            level: .info,
            message: "Will Present Notification: \(notification.request.content)"
        )
        
        pushNotificationPublisher.send(notification)
        completionHandler([.banner, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        self.log(
            level: .info,
            message: "Did Receive Notification: \(response.notification.request.content)"
        )
        
        pushNotificationTappedPublisher.send(response.notification)
        completionHandler()
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        UNUserNotificationCenter.current().setBadgeCount(0) { [weak self] error in
            
            if let error = error {
                
                self?.logError(
                    title: "App Delegate App Badge Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        self.log(
            level: .info,
            message: "App Will Terminate"
        )
        
        appWillTerminatePublisher.send()
        
    }
    
}

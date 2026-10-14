//
//  AppDelegate.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import SwiftUI
import UIKit
import UserNotificationsUI
import Combine
import FirebaseCore
@preconcurrency import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate, @preconcurrency MessagingDelegate, Loggable {

    internal let loggerName: String = "APP_DELEGATE"
    internal let loggerEmoji: String = "🪈"

    private(set) var deviceTokenPublisher = CurrentValueSubject<String?, Never>(nil)
    private(set) var pushNotificationPublisher = PassthroughSubject<UNNotification, Never>()
    private(set) var pushNotificationTappedPublisher = PassthroughSubject<UNNotification, Never>()
    private(set) var appWillTerminatePublisher = PassthroughSubject<Void, Never>()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        #if !LEAFLAUNCH_MOCK
            FirebaseApp.configureIfNeeded()
            Messaging.messaging().delegate = self

            UIApplication.shared.registerForRemoteNotifications()
        #endif

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setBadgeCount(0) { [weak self] error in

            if let error = error {

                Task { @MainActor [weak self] in

                    self?.logError(
                        title: "App Delegate App Badge Error",
                        message: error.getMessageForError()
                    )

                }

            }

        }

        return true

    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        #if !LEAFLAUNCH_MOCK
            Messaging.messaging().apnsToken = deviceToken

            Messaging.messaging().token { [weak self] token, error in

                Task { @MainActor [weak self] in

                    if let error {
                        self?.logError(
                            title: "FCM Registration Token Error",
                            message: error.getMessageForError()
                        )
                        return
                    }

                    if let token {
                        self?.publishFCMToken(token)
                    }

                }

            }
        #endif

    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        #if !LEAFLAUNCH_MOCK
            guard messaging.apnsToken != nil, let fcmToken else { return }
            self.publishFCMToken(fcmToken)
        #endif

    }

    private func publishFCMToken(_ token: String) {

        guard self.deviceTokenPublisher.value != token else { return }
        self.deviceTokenPublisher.send(token)

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

                Task { @MainActor [weak self] in

                    self?.logError(
                        title: "App Delegate App Badge Error",
                        message: error.getMessageForError()
                    )

                }

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

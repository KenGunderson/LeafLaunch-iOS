//
//  LocalNotificationService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

// TODO: - PASS METADATA DICT to content info

import Combine
@preconcurrency import UserNotifications
import UIKit

final class LocalNotificationService: LocalNotificationServiceProtocol {
    
    internal let loggerName: String = "LOCAL_NOTIFICATION_SERVICE"
    internal let loggerEmoji: String = "⏰"
    
    @Published private(set) var permissionGranted: Bool = false
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> {
        return self.$permissionGranted.eraseToAnyPublisher()
    }
    
    @Published private(set) var shouldPromptForPermissions: Bool = false
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> {
        return self.$shouldPromptForPermissions.eraseToAnyPublisher()
    }
    
    private let notificationCenter: UNUserNotificationCenter
    
    init(notificationCenter: UNUserNotificationCenter = .current()) {
        
        self.notificationCenter = notificationCenter
        self.logInit()
        self.refreshAuthorizationStatus()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func refreshAuthorizationStatus() {
        
        Task { [weak self] in
            
            guard let self else { return }
            
            let settings = await self.notificationCenter.notificationSettings()
            let status = settings.authorizationStatus
            
            await MainActor.run { [weak self] in
                
                guard let self else { return }
                self.updateAuthorizationState(status)
                
            }
            
            self.log(message: "Refreshed authorization status: \(status.rawValue)")
            
        }
        
    }
    
    func requestPermissionIfNeeded() {
        
        self.log(message: "Request permission if needed: \(self.shouldPromptForPermissions)")
        
        if self.shouldPromptForPermissions {
            self.requestPermission()
        }
        
    }
    
    func requestPermission() {
        
        self.log(message: "Requesting local notification permission")
        
        Task { [weak self] in
            
            guard let self else { return }
            
            do {
                
                let isGranted = try await self.notificationCenter.requestAuthorization(options: [
                    .alert,
                    .sound,
                    .badge
                ])
                
                await MainActor.run {
                    
                    self.permissionGranted = isGranted
                    self.shouldPromptForPermissions = false
                    
                    UIApplication.shared.registerForRemoteNotifications()
                    
                }
                
                self.log(message: "Permission request result: \(isGranted)")
                self.refreshAuthorizationStatus()
                
            }
            catch {
                
                self.logError(
                    title: "Local Notification Permission Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
    }
    
    func schedule(_ request: LocalNotificationScheduleRequest) async throws {
        
        self.log(message: """
        Scheduling local notification
        mode: \(request.mode.rawValue)
        interval_seconds: \(request.triggerIntervalSeconds)
        unit: \(request.timeSpan.rawValue)
        value: \(request.incrementalNumber)
        """)
        
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.userInfo = [
            "source": "local_notification_service",
            "mode": request.mode.rawValue,
            "incremental_number": request.incrementalNumber,
            "time_span": request.timeSpan.rawValue
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: request.triggerIntervalSeconds,
            repeats: request.mode == .recurring
        )
        
        let identifier = "local.notification.\(UUID().uuidString)"
        
        let localRequest = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            
            try await self.notificationCenter.add(localRequest)
            
            self.log(message: """
            Scheduled local notification
            id: \(identifier)
            mode: \(request.mode.rawValue)
            interval_seconds: \(request.triggerIntervalSeconds)
            """)
            
        }
        catch {
            
            self.logError(
                title: "Local Notification Schedule Error",
                message: error.getMessageForError()
            )
            
            throw error
            
        }
        
    }
    
    func getPlannedNotifications() async -> [LocalNotificationSnapshotItem] {
        
        let requests = await self.notificationCenter.pendingNotificationRequests()
        
        let mappedItems = requests.map { request in
            
            let triggerDate = self.nextTriggerDate(for: request.trigger)
            
            let relativeDescription: String = {
                
                guard let triggerDate else { return "Unknown trigger time" }
                
                let formatted = triggerDate.preciseFutureRelativeString(
                    unitStyle: .full,
                    allowedUnites: [.minute, .hour, .day, .weekOfMonth],
                    maximumUnitCount: 2
                )
                
                if formatted == "0 minutes" {
                    return "in now"
                }
                
                return "in \(formatted)"
                
            }()
            
            return LocalNotificationSnapshotItem(
                id: request.identifier,
                title: request.content.title.trimmed().isEmpty ? "No Title" : request.content.title,
                body: request.content.body.trimmed().isEmpty ? "No Message" : request.content.body,
                category: .planned,
                date: triggerDate,
                isRepeating: request.trigger?.repeats ?? false,
                relativeDescription: relativeDescription
            )
            
        }
        
        let sorted = mappedItems.sorted { lhs, rhs in
            
            switch (lhs.date, rhs.date) {
            case (.some(let lhsDate), .some(let rhsDate)):
                return lhsDate < rhsDate
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return lhs.id < rhs.id
            }
            
        }
        
        self.log(message: "Fetched planned notifications: \(sorted.count)")
        
        return sorted
        
    }
    
    func getIncomingNotifications() async -> [LocalNotificationSnapshotItem] {
        
        let notifications = await self.notificationCenter.deliveredNotifications()
        
        let mappedItems = notifications.map { notification in
            
            let incomingDate = notification.date
            
            let relativeDescription: String = {
                
                let formatted = incomingDate.preciseRelativeString(
                    unitStyle: .full,
                    allowedUnites: [.minute, .hour, .day, .weekOfMonth],
                    maximumUnitCount: 2
                )
                
                if formatted == "0 minutes" {
                    return "now"
                }
                
                return "\(formatted) ago"
                
            }()
            
            return LocalNotificationSnapshotItem(
                id: notification.request.identifier,
                title: notification.request.content.title.trimmed().isEmpty ? "No Title" : notification.request.content.title,
                body: notification.request.content.body.trimmed().isEmpty ? "No Message" : notification.request.content.body,
                category: .incoming,
                date: incomingDate,
                isRepeating: notification.request.trigger?.repeats ?? false,
                relativeDescription: relativeDescription
            )
            
        }
        
        let sorted = mappedItems.sorted { lhs, rhs in
            
            switch (lhs.date, rhs.date) {
            case (.some(let lhsDate), .some(let rhsDate)):
                return lhsDate > rhsDate
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return lhs.id < rhs.id
            }
            
        }
        
        self.log(message: "Fetched incoming notifications: \(sorted.count)")
        
        return sorted
        
    }
    
    func clearPlannedNotifications() {
        
        self.notificationCenter.removeAllPendingNotificationRequests()
        self.log(message: "Cleared all planned notifications")
        
    }
    
    func clearIncomingNotifications() {
        
        self.notificationCenter.removeAllDeliveredNotifications()
        self.log(message: "Cleared all incoming notifications")
        
    }
    
    func clearAllNotifications() {
        
        self.notificationCenter.removeAllPendingNotificationRequests()
        self.notificationCenter.removeAllDeliveredNotifications()
        
        self.log(message: "Cleared all planned and incoming notifications")
        
    }
    
    private func updateAuthorizationState(_ status: UNAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = true
            
        case .authorized, .provisional, .ephemeral:
            
            self.permissionGranted = true
            self.shouldPromptForPermissions = false
            
        default:
            
            self.permissionGranted = false
            self.shouldPromptForPermissions = false
        }
        
    }
    
    private func nextTriggerDate(for trigger: UNNotificationTrigger?) -> Date? {
        
        if let calendarTrigger = trigger as? UNCalendarNotificationTrigger {
            return calendarTrigger.nextTriggerDate()
        }
        
        if let timeIntervalTrigger = trigger as? UNTimeIntervalNotificationTrigger {
            return Date().addingTimeInterval(timeIntervalTrigger.timeInterval)
        }
        
        return nil
        
    }
    
}

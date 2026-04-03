//
//  LocalNotificationService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

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
    private let recurrenceCalculator = LocalNotificationRecurrenceCalculator()
    
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
        
        if case .calendarType(let rule) = request.strategy,
           request.mode == .recurring,
           rule.cadence == .week,
           case .weekly(let weekdays) = rule.calendarSelector,
           Array(Set(weekdays)).count > 1 {
            
            try await self.scheduleCalendarTypeWeeklyFanOut(
                request: request,
                rule: rule,
                weekdays: weekdays
            )
            
            return
        }
        
        try await self.schedule(
            request,
            identifier: "local.notification.\(UUID().uuidString)",
            preferredTriggerDate: nil
        )
        
    }
    
    func decodeScheduledLocalNotification(from notification: UNNotification) -> LocalNotificationPayload? {
        
        let payload = notification.request.content.userInfo
        
        guard self.isLocalPayload(payload) else {
            return nil
        }
        
        guard let modeRawValue = payload[UserInfoKey.mode] as? String,
              let mode = LocalNotificationScheduleMode(rawValue: modeRawValue),
              let strategy = self.parseStrategy(from: payload)
        else {
            return nil
        }
        
        let request = LocalNotificationScheduleRequest(
            strategy: strategy,
            mode: mode,
            title: notification.request.content.title,
            body: notification.request.content.body,
            metadata: self.parseMetadata(from: payload)
        )
        
        return LocalNotificationPayload(
            identifier: notification.request.identifier,
            request: request
        )
        
    }
    
    func remakeScheduledLocalNotificationIfNeeded(from notification: UNNotification) async {
        
        guard let payload = self.decodeScheduledLocalNotification(from: notification) else {
            return
        }
        
        guard payload.request.mode == .recurring,
              let rule = payload.request.recurrenceRule
        else {
            return
        }
        
        let pattern = payload.request.strategy.pattern
        
        guard pattern == .anchored || pattern == .calendarType else {
            return
        }
        
        let usesRepeatingCalendarTrigger = self.recurrenceCalculator
            .supportsRepeatingCalendarTrigger(
                for: rule,
                pattern: pattern
            )
        
        if usesRepeatingCalendarTrigger {
            return
        }
        
        guard let nextTriggerDate = self.nextRollingTriggerDate(
            for: rule,
            pattern: pattern,
            previousOccurrence: notification.date,
            referenceDate: Date()
        ) else {
            return
        }
        
        var metadata = payload.request.metadata
        metadata["remade_from_notification_id"] = notification.request.identifier
        
        let remadeRequest = LocalNotificationScheduleRequest(
            strategy: payload.request.strategy,
            mode: payload.request.mode,
            title: payload.request.title,
            body: payload.request.body,
            metadata: metadata
        )
        
        do {
            
            try await self.schedule(
                remadeRequest,
                identifier: "local.notification.\(UUID().uuidString)",
                preferredTriggerDate: nextTriggerDate
            )
            
            self.log(message: "Remade local notification from \(notification.request.identifier)")
            
        }
        catch {
            
            self.logError(
                title: "Remake Local Notification Error",
                message: error.getMessageForError()
            )
            
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
                    allowedUnites: [.minute, .hour, .day, .weekOfMonth, .month, .year],
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
                    allowedUnites: [.minute, .hour, .day, .weekOfMonth, .month, .year],
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
    
    private func scheduleCalendarTypeWeeklyFanOut(request: LocalNotificationScheduleRequest,
                                                   rule: LocalNotificationRecurrenceRule,
                                                   weekdays: [LocalNotificationWeekday]) async throws {
        
        let normalizedWeekdays = Array(Set(weekdays))
            .sorted { $0.rawValue < $1.rawValue }
        
        guard !normalizedWeekdays.isEmpty else {
            throw NSError(
                domain: "LocalNotificationService",
                code: 10,
                userInfo: [NSLocalizedDescriptionKey: "At least one weekday is required."]
            )
        }
        
        let groupIdentifier = "local.notification.group.\(UUID().uuidString)"
        
        for weekday in normalizedWeekdays {
            
            var metadata = request.metadata
            metadata["calendar_group_id"] = groupIdentifier
            metadata["calendar_group_weekday"] = "\(weekday.rawValue)"
            
            let childRule = LocalNotificationRecurrenceRule(
                cadence: .week,
                interval: rule.interval,
                hour: rule.hour,
                minute: rule.minute,
                anchoredBoundary: nil,
                calendarSelector: .weekly(weekdays: [weekday])
            )
            
            let childRequest = LocalNotificationScheduleRequest(
                strategy: .calendarType(rule: childRule),
                mode: request.mode,
                title: request.title,
                body: request.body,
                metadata: metadata
            )
            
            try await self.schedule(
                childRequest,
                identifier: "\(groupIdentifier).\(weekday.rawValue).\(UUID().uuidString)",
                preferredTriggerDate: nil,
                additionalUserInfo: [
                    UserInfoKey.groupIdentifier: groupIdentifier,
                    UserInfoKey.groupWeekday: weekday.rawValue,
                    UserInfoKey.groupSize: normalizedWeekdays.count
                ]
            )
            
        }
        
    }
    
    private func schedule(_ request: LocalNotificationScheduleRequest,
                          identifier: String,
                          preferredTriggerDate: Date?,
                          additionalUserInfo: [AnyHashable: Any] = [:]) async throws {
        
        self.log(message: self.scheduleLogMessage(for: request))
        
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.userInfo = self.userInfo(
            for: request,
            identifier: identifier,
            additionalUserInfo: additionalUserInfo
        )
        
        let trigger = try self.trigger(
            for: request,
            preferredTriggerDate: preferredTriggerDate
        )
        
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
            strategy: \(request.strategy.pattern.rawValue)
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
    
    private func trigger(for request: LocalNotificationScheduleRequest,
                         preferredTriggerDate: Date?) throws -> UNNotificationTrigger {
        
        switch request.strategy {
        case .interval:
            
            guard let triggerIntervalSeconds = request.triggerIntervalSeconds else {
                throw NSError(
                    domain: "LocalNotificationService",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing interval trigger seconds."]
                )
            }
            
            return UNTimeIntervalNotificationTrigger(
                timeInterval: triggerIntervalSeconds,
                repeats: request.mode == .recurring
            )
            
        case .anchored(let rule), .calendarType(let rule):
            
            let pattern = request.strategy.pattern
            
            if request.mode == .recurring,
               preferredTriggerDate == nil,
               let repeatingComponents = self.recurrenceCalculator.repeatingDateComponents(
                    for: rule,
                    pattern: pattern
               ) {
                
                return UNCalendarNotificationTrigger(
                    dateMatching: repeatingComponents,
                    repeats: true
                )
            }
            
            let triggerDate: Date?
            
            if let preferredTriggerDate {
                triggerDate = preferredTriggerDate
            }
            else {
                triggerDate = self.recurrenceCalculator.nextOccurrence(
                    for: rule,
                    pattern: pattern,
                    after: Date()
                )
            }
            
            guard let triggerDate else {
                throw NSError(
                    domain: "LocalNotificationService",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to compute recurrence trigger date."]
                )
            }
            
            let calendar = Calendar.autoupdatingCurrent
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: triggerDate
            )
            
            return UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
        }
        
    }
    
    private func nextRollingTriggerDate(for rule: LocalNotificationRecurrenceRule,
                                        pattern: LocalNotificationSchedulePattern,
                                        previousOccurrence: Date,
                                        referenceDate: Date) -> Date? {
        
        guard var candidate = self.recurrenceCalculator.nextOccurrenceAfterPrevious(
            for: rule,
            pattern: pattern,
            previousOccurrence: previousOccurrence
        ) else {
            return nil
        }
        
        while candidate <= referenceDate {
            
            guard let nextCandidate = self.recurrenceCalculator.nextOccurrenceAfterPrevious(
                for: rule,
                pattern: pattern,
                previousOccurrence: candidate
            ) else {
                return nil
            }
            
            candidate = nextCandidate
            
        }
        
        return candidate
        
    }
    
    private func scheduleLogMessage(for request: LocalNotificationScheduleRequest) -> String {
        
        switch request.strategy {
        case .interval(let number, let timeSpan):
            return """
            Scheduling local notification
            mode: \(request.mode.rawValue)
            pattern: interval
            value: \(number)
            unit: \(timeSpan.rawValue)
            trigger_interval_seconds: \(request.triggerIntervalSeconds ?? 0)
            """
        
        case .anchored(let rule), .calendarType(let rule):
            return """
            Scheduling local notification
            mode: \(request.mode.rawValue)
            pattern: \(request.strategy.pattern.rawValue)
            cadence: \(rule.cadence.rawValue)
            interval: \(rule.interval)
            hour: \(rule.hour)
            minute: \(rule.minute)
            boundary: \(rule.anchoredBoundary?.rawValue ?? "none")
            selector: \(self.selectorDescription(rule.calendarSelector))
            """
        }
        
    }
    
    private func selectorDescription(_ selector: LocalNotificationCalendarSelector?) -> String {
        
        switch selector {
        case .none:
            return "none"
        case .weekly(let weekdays):
            return "weekly:\(weekdays.map(\.rawValue).sorted())"
        case .monthly(let dayOfMonth):
            return "monthly:\(dayOfMonth)"
        case .yearly(let month, let dayOfMonth):
            return "yearly:\(month)-\(dayOfMonth)"
        }
        
    }
    
    private func parseStrategy(from payload: [AnyHashable: Any]) -> LocalNotificationScheduleStrategy? {
        
        guard let patternRawValue = payload[UserInfoKey.schedulePattern] as? String,
              let pattern = LocalNotificationSchedulePattern(rawValue: patternRawValue)
        else {
            return nil
        }
        
        switch pattern {
        case .interval:
            
            guard let number = self.intValue(from: payload[UserInfoKey.incrementalNumber]),
                  let rawTimeSpan = payload[UserInfoKey.timeSpan] as? String,
                  let timeSpan = LocalNotificationTimeSpan(rawValue: rawTimeSpan)
            else {
                return nil
            }
            
            return .interval(
                number: number,
                timeSpan: timeSpan
            )
            
        case .anchored, .calendarType:
            
            guard let recurrenceRule = self.parseRecurrenceRule(from: payload),
                  recurrenceRule.isValid(for: pattern)
            else {
                return nil
            }
            
            if pattern == .anchored {
                return .anchored(rule: recurrenceRule)
            }
            
            return .calendarType(rule: recurrenceRule)
        }
        
    }
    
    private func parseRecurrenceRule(from payload: [AnyHashable: Any]) -> LocalNotificationRecurrenceRule? {
        
        guard let cadenceRawValue = payload[UserInfoKey.recurrenceCadence] as? String,
              let cadence = LocalNotificationRecurrenceCadence(rawValue: cadenceRawValue)
        else {
            return nil
        }
        
        let interval = self.intValue(from: payload[UserInfoKey.recurrenceInterval]) ?? 1
        let hour = self.intValue(from: payload[UserInfoKey.recurrenceHour]) ?? 8
        let minute = self.intValue(from: payload[UserInfoKey.recurrenceMinute]) ?? 0
        
        let anchoredBoundary: LocalNotificationRecurrenceBoundary?
        
        if let boundaryRawValue = payload[UserInfoKey.recurrenceBoundary] as? String {
            anchoredBoundary = LocalNotificationRecurrenceBoundary(rawValue: boundaryRawValue)
        }
        else {
            anchoredBoundary = nil
        }
        
        let calendarSelector: LocalNotificationCalendarSelector?
        
        if let selectorType = payload[UserInfoKey.recurrenceSelectorType] as? String,
           selectorType == UserInfoValue.selectorWeekly {
            
            let weekdays = self.weekdaysValue(from: payload[UserInfoKey.recurrenceWeekdays])
            calendarSelector = .weekly(weekdays: weekdays)
            
        }
        else if let selectorType = payload[UserInfoKey.recurrenceSelectorType] as? String,
                selectorType == UserInfoValue.selectorMonthly,
                let dayOfMonth = self.intValue(from: payload[UserInfoKey.recurrenceDayOfMonth]) {
            
            calendarSelector = .monthly(dayOfMonth: dayOfMonth)
            
        }
        else if let selectorType = payload[UserInfoKey.recurrenceSelectorType] as? String,
                selectorType == UserInfoValue.selectorYearly,
                let month = self.intValue(from: payload[UserInfoKey.recurrenceMonth]),
                let dayOfMonth = self.intValue(from: payload[UserInfoKey.recurrenceDayOfMonth]) {
            
            calendarSelector = .yearly(
                month: month,
                dayOfMonth: dayOfMonth
            )
            
        }
        else {
            calendarSelector = nil
        }
        
        return LocalNotificationRecurrenceRule(
            cadence: cadence,
            interval: interval,
            hour: hour,
            minute: minute,
            anchoredBoundary: anchoredBoundary,
            calendarSelector: calendarSelector
        )
        
    }
    
    private func parseMetadata(from payload: [AnyHashable: Any]) -> [String: String] {
        
        if let metadata = payload[UserInfoKey.metadata] as? [String: String] {
            return metadata
        }
        
        if let metadata = payload[UserInfoKey.metadata] as? [String: Any] {
            
            return metadata.reduce(into: [String: String]()) { partialResult, item in
                
                if let value = item.value as? String {
                    partialResult[item.key] = value
                }
                
            }
            
        }
        
        var metadata: [String: String] = [:]
        
        payload.forEach { key, value in
            
            guard let keyString = key as? String,
                  keyString.hasPrefix("metadata."),
                  let valueString = value as? String
            else {
                return
            }
            
            let metadataKey = keyString.replacingOccurrences(of: "metadata.", with: "")
            metadata[metadataKey] = valueString
            
        }
        
        return metadata
        
    }
    
    private func isLocalPayload(_ payload: [AnyHashable: Any]) -> Bool {
        
        if let explicitSource = payload[UserInfoKey.notificationSource] as? String,
           explicitSource.lowercased() == "local" {
            return true
        }
        
        if let payloadType = payload[UserInfoKey.payloadType] as? String,
           payloadType.lowercased() == "local" {
            return true
        }
        
        if let source = payload[UserInfoKey.source] as? String,
           source == "local_notification_service" {
            return true
        }
        
        return false
        
    }
    
    private func intValue(from rawValue: Any?) -> Int? {
        
        if let intValue = rawValue as? Int {
            return intValue
        }
        
        if let numberValue = rawValue as? NSNumber {
            return numberValue.intValue
        }
        
        if let stringValue = rawValue as? String {
            return Int(stringValue)
        }
        
        return nil
        
    }
    
    private func weekdaysValue(from rawValue: Any?) -> [LocalNotificationWeekday] {
        
        if let weekdays = rawValue as? [Int] {
            return weekdays.compactMap(LocalNotificationWeekday.init(rawValue:))
        }
        
        if let weekdays = rawValue as? [NSNumber] {
            return weekdays
                .map(\.intValue)
                .compactMap(LocalNotificationWeekday.init(rawValue:))
        }
        
        if let weekdays = rawValue as? [String] {
            return weekdays
                .compactMap(Int.init)
                .compactMap(LocalNotificationWeekday.init(rawValue:))
        }
        
        return []
        
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
    
    private func userInfo(for request: LocalNotificationScheduleRequest,
                          identifier: String,
                          additionalUserInfo: [AnyHashable: Any]) -> [AnyHashable: Any] {
        
        var userInfo: [AnyHashable: Any] = [
            UserInfoKey.source: "local_notification_service",
            UserInfoKey.notificationSource: "local",
            UserInfoKey.payloadType: "local",
            UserInfoKey.notificationIdentifier: identifier,
            UserInfoKey.mode: request.mode.rawValue,
            UserInfoKey.schedulePattern: request.strategy.pattern.rawValue,
            UserInfoKey.isRecurring: request.mode == .recurring,
            UserInfoKey.scheduledAtUnix: Date().timeIntervalSince1970
        ]
        
        switch request.strategy {
        case .interval(let number, let timeSpan):
            
            userInfo[UserInfoKey.incrementalNumber] = number
            userInfo[UserInfoKey.timeSpan] = timeSpan.rawValue
            
            if let intervalSeconds = request.intervalSeconds {
                userInfo[UserInfoKey.intervalSeconds] = intervalSeconds
            }
            
            if let triggerIntervalSeconds = request.triggerIntervalSeconds {
                userInfo[UserInfoKey.triggerIntervalSeconds] = triggerIntervalSeconds
            }
            
        case .anchored(let rule), .calendarType(let rule):
            
            userInfo[UserInfoKey.recurrenceCadence] = rule.cadence.rawValue
            userInfo[UserInfoKey.recurrenceInterval] = rule.interval
            userInfo[UserInfoKey.recurrenceHour] = rule.hour
            userInfo[UserInfoKey.recurrenceMinute] = rule.minute
            
            if let boundary = rule.anchoredBoundary?.rawValue {
                userInfo[UserInfoKey.recurrenceBoundary] = boundary
            }
            
            switch rule.calendarSelector {
            case .none:
                break
                
            case .weekly(let weekdays):
                userInfo[UserInfoKey.recurrenceSelectorType] = UserInfoValue.selectorWeekly
                userInfo[UserInfoKey.recurrenceWeekdays] = weekdays.map(\.rawValue)
                
            case .monthly(let dayOfMonth):
                userInfo[UserInfoKey.recurrenceSelectorType] = UserInfoValue.selectorMonthly
                userInfo[UserInfoKey.recurrenceDayOfMonth] = dayOfMonth
                
            case .yearly(let month, let dayOfMonth):
                userInfo[UserInfoKey.recurrenceSelectorType] = UserInfoValue.selectorYearly
                userInfo[UserInfoKey.recurrenceMonth] = month
                userInfo[UserInfoKey.recurrenceDayOfMonth] = dayOfMonth
            }
        }
        
        if !request.metadata.isEmpty {
            
            userInfo[UserInfoKey.metadata] = request.metadata
            
            request.metadata.forEach { key, value in
                userInfo["metadata.\(key)"] = value
            }
            
        }
        
        additionalUserInfo.forEach { key, value in
            userInfo[key] = value
        }
        
        return userInfo
        
    }
    
}

private enum UserInfoKey {
    
    static let source = "source"
    static let payloadType = "payload_type"
    static let notificationSource = "notification_source"
    static let notificationIdentifier = "notification_id"
    
    static let mode = "mode"
    static let schedulePattern = "schedule_pattern"
    static let isRecurring = "is_recurring"
    static let scheduledAtUnix = "scheduled_at_unix"
    
    static let incrementalNumber = "incremental_number"
    static let timeSpan = "time_span"
    static let intervalSeconds = "interval_seconds"
    static let triggerIntervalSeconds = "trigger_interval_seconds"
    
    static let recurrenceCadence = "recurrence_cadence"
    static let recurrenceInterval = "recurrence_interval"
    static let recurrenceHour = "recurrence_hour"
    static let recurrenceMinute = "recurrence_minute"
    static let recurrenceBoundary = "recurrence_boundary"
    static let recurrenceSelectorType = "recurrence_selector_type"
    static let recurrenceWeekdays = "recurrence_weekdays"
    static let recurrenceDayOfMonth = "recurrence_day_of_month"
    static let recurrenceMonth = "recurrence_month"
    
    static let groupIdentifier = "calendar_group_id"
    static let groupWeekday = "calendar_group_weekday"
    static let groupSize = "calendar_group_size"
    
    static let metadata = "metadata"
    
}

private enum UserInfoValue {
    
    static let selectorWeekly = "weekly"
    static let selectorMonthly = "monthly"
    static let selectorYearly = "yearly"
    
}

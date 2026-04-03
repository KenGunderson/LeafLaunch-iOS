//
//  DevLocalNotificationsViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

import SwiftUI
import Combine

final class DevLocalNotificationsViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let localNotificationService: LocalNotificationServiceProtocol
    private let recurrenceCalculator = LocalNotificationRecurrenceCalculator()
    
    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var refreshTask: Task<Void, Never>?
    private var scheduleTask: Task<Void, Never>?
    
    @Published var selectedModeString: String? = LocalNotificationScheduleMode.oneTime.displayName
    @Published var selectedPatternString: String? = LocalNotificationSchedulePattern.interval.displayName
    
    @Published var selectedTimeSpanString: String? = LocalNotificationTimeSpan.minute.displayName
    @Published var selectedCadenceString: String? = LocalNotificationRecurrenceCadence.day.displayName
    @Published var selectedWeekdayString: String? = LocalNotificationWeekday.monday.displayName
    
    @Published var incrementalNumberText: String = "1"
    @Published var anchorHourText: String = "8"
    @Published var anchorMinuteText: String = "0"
    
    @Published private(set) var plannedNotifications: [LocalNotificationSnapshotItem] = []
    @Published private(set) var incomingNotifications: [LocalNotificationSnapshotItem] = []
    
    @Published private(set) var isPermissionGranted: Bool = false
    @Published private(set) var shouldPromptForPermissions: Bool = false
    @Published private(set) var isLoading: Bool = false
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         localNotificationService: LocalNotificationServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        self.localNotificationService = localNotificationService
        
        self.logInit()
        
    }
    
    isolated deinit {
        
        self.refreshTask?.cancel()
        self.scheduleTask?.cancel()
        self.logDeinit()
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func handleFirstAppear() {
        
        track()
        bindSubscribers()
        self.localNotificationService.refreshAuthorizationStatus()
        self.refreshNotifications()
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    var allModeOptions: [String] {
        return LocalNotificationScheduleMode.allCases.map(\.displayName)
    }
    
    var allPatternOptions: [String] {
        return LocalNotificationSchedulePattern.allCases.map(\.displayName)
    }
    
    var allTimeSpanOptions: [String] {
        return LocalNotificationTimeSpan.allCases.map(\.displayName)
    }
    
    var allCadenceOptions: [String] {
        return LocalNotificationRecurrenceCadence.allCases.map(\.displayName)
    }
    
    var allWeekdayOptions: [String] {
        return LocalNotificationWeekday.allCases.map(\.displayName)
    }
    
    var selectedMode: LocalNotificationScheduleMode {
        
        let fallback = LocalNotificationScheduleMode.oneTime
        
        guard let selectedModeString else {
            return fallback
        }
        
        return LocalNotificationScheduleMode
            .allCases
            .first(where: { $0.displayName == selectedModeString }) ?? fallback
        
    }
    
    var selectedPattern: LocalNotificationSchedulePattern {
        
        let fallback = LocalNotificationSchedulePattern.interval
        
        guard let selectedPatternString else {
            return fallback
        }
        
        return LocalNotificationSchedulePattern
            .allCases
            .first(where: { $0.displayName == selectedPatternString }) ?? fallback
        
    }
    
    var selectedTimeSpan: LocalNotificationTimeSpan {
        
        let fallback = LocalNotificationTimeSpan.minute
        
        guard let selectedTimeSpanString else {
            return fallback
        }
        
        return LocalNotificationTimeSpan
            .allCases
            .first(where: { $0.displayName == selectedTimeSpanString }) ?? fallback
        
    }
    
    var selectedCadence: LocalNotificationRecurrenceCadence {
        
        let fallback = LocalNotificationRecurrenceCadence.day
        
        guard let selectedCadenceString else {
            return fallback
        }
        
        return LocalNotificationRecurrenceCadence
            .allCases
            .first(where: { $0.displayName == selectedCadenceString }) ?? fallback
        
    }
    
    var selectedWeekday: LocalNotificationWeekday {
        
        let fallback = LocalNotificationWeekday.monday
        
        guard let selectedWeekdayString else {
            return fallback
        }
        
        return LocalNotificationWeekday
            .allCases
            .first(where: { $0.displayName == selectedWeekdayString }) ?? fallback
        
    }
    
    var incrementalNumber: Int {
        
        let parsedNumber = Int(self.incrementalNumberText) ?? 0
        return max(parsedNumber, 0)
        
    }
    
    var anchorHour: Int? {
        return Int(self.anchorHourText)
    }
    
    var anchorMinute: Int? {
        return Int(self.anchorMinuteText)
    }
    
    var shouldShowIntervalControls: Bool {
        return self.selectedPattern == .interval
    }
    
    var shouldShowAnchoredControls: Bool {
        return self.selectedPattern == .anchored
    }
    
    var shouldShowWeekdayControl: Bool {
        return self.selectedPattern == .anchored && self.selectedCadence == .week
    }
    
    var isScheduleValid: Bool {
        
        guard self.incrementalNumber >= 1 else {
            return false
        }
        
        switch self.selectedPattern {
        case .interval:
            return true
        case .anchored:
            guard let anchorHour else { return false }
            guard let anchorMinute else { return false }
            guard (0...23).contains(anchorHour) else { return false }
            guard (0...59).contains(anchorMinute) else { return false }
            return self.anchoredRule != nil
        }
        
    }
    
    var schedulePreviewText: String {
        
        switch self.selectedPattern {
        case .interval:
            
            let unit = self.incrementalNumber == 1
            ? self.selectedTimeSpan.displayName.lowercased()
            : self.selectedTimeSpan.displayNamePlural.lowercased()
            
            switch self.selectedMode {
            case .oneTime:
                return "Will fire in \(self.incrementalNumber) \(unit)"
            case .recurring:
                return "Will fire every \(self.incrementalNumber) \(unit)"
            }
            
        case .anchored:
            
            guard let anchorHour else {
                return "Enter a valid anchor hour (0-23)."
            }
            
            guard let anchorMinute else {
                return "Enter a valid anchor minute (0-59)."
            }
            
            let cadenceLabel = self.selectedCadence.displayName.lowercased()
            let cadenceTitle: String
            
            if self.selectedCadence == .week {
                cadenceTitle = "\(self.selectedWeekday.displayName)"
            }
            else {
                cadenceTitle = cadenceLabel
            }
            
            let timeLabel = String(format: "%02d:%02d", anchorHour, anchorMinute)
            
            switch self.selectedMode {
            case .oneTime:
                return "Will fire on next \(cadenceTitle) at \(timeLabel) local time"
            case .recurring:
                return "Will fire every \(self.incrementalNumber) \(cadenceLabel)(s) on \(cadenceTitle) at \(timeLabel)"
            }
        }
        
    }
    
    var nextOccurrencesPreviewText: String {
        
        guard self.selectedPattern == .anchored,
              let rule = self.anchoredRule
        else {
            return ""
        }
        
        let previewDates = self.recurrenceCalculator.nextOccurrences(
            for: rule,
            after: Date(),
            count: 3
        )
        
        if previewDates.isEmpty {
            return ""
        }
        
        let lines = previewDates.enumerated().map { index, date in
            let formattedDate = date.formatted(
                .dateTime
                    .weekday()
                    .day()
                    .month()
                    .year()
                    .hour()
                    .minute()
            )
            return "\(index + 1). \(formattedDate)"
        }
        
        return lines.joined(separator: "\n")
        
    }
    
    func requestPermission() {
        
        self.log(message: "Request notification permission tapped")
        self.localNotificationService.requestPermission()
        
    }
    
    func refreshNotifications() {
        
        self.log(message: "Refreshing planned and incoming notifications")
        
        self.refreshTask?.cancel()
        
        self.refreshTask = Task { @MainActor [weak self] in
            
            guard let self else { return }
            
            self.isLoading = true
            
            async let planned = self.localNotificationService.getPlannedNotifications()
            async let incoming = self.localNotificationService.getIncomingNotifications()
            
            let plannedResults = await planned
            let incomingResults = await incoming
            
            guard !Task.isCancelled else { return }
            
            self.plannedNotifications = plannedResults
            self.incomingNotifications = incomingResults
            self.isLoading = false
            
            self.log(
                message: "Refreshed notification data planned: \(plannedResults.count), incoming: \(incomingResults.count)"
            )
            
        }
        
    }
    
    func scheduleNotification() {
        
        guard self.isScheduleValid else {
            
            self.logError(
                title: "Invalid Local Notification Input",
                message: "Please provide a valid schedule configuration."
            )
            
            return
            
        }
        
        guard let strategy = self.scheduleStrategy else {
            
            self.logError(
                title: "Invalid Schedule Strategy",
                message: "Unable to build schedule strategy from current input."
            )
            
            return
        }
        
        let mode = self.selectedMode
        let title = mode == .oneTime
        ? "Scheduled Local Notification"
        : "Recurring Local Notification"
        
        let body = self.schedulePreviewText
        
        let request = LocalNotificationScheduleRequest(
            strategy: strategy,
            mode: mode,
            title: title,
            body: body,
            metadata: [
                "scheduled_by": "dev_local_notifications",
                "screen": "dev_settings_local_notifications"
            ]
        )
        
        self.scheduleTask?.cancel()
        
        self.scheduleTask = Task { [weak self] in
            
            guard let self else { return }
            
            do {
                
                try await self.localNotificationService.schedule(request)
                
                await MainActor.run { [weak self] in
                    self?.refreshNotifications()
                }
                
            }
            catch {
                
                self.logError(
                    title: "Schedule Local Notification Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
    }
    
    func clearPlannedNotifications() {
        
        self.log(message: "Clear planned notifications tapped")
        self.localNotificationService.clearPlannedNotifications()
        self.refreshNotifications()
        
    }
    
    func clearIncomingNotifications() {
        
        self.log(message: "Clear incoming notifications tapped")
        self.localNotificationService.clearIncomingNotifications()
        self.refreshNotifications()
        
    }
    
    func clearAllNotifications() {
        
        self.log(message: "Clear all notifications tapped")
        self.localNotificationService.clearAllNotifications()
        self.refreshNotifications()
        
    }
    
    private var anchoredRule: LocalNotificationRecurrenceRule? {
        
        guard let anchorHour else { return nil }
        guard let anchorMinute else { return nil }
        
        switch self.selectedCadence {
        case .day:
            return .startOfDay(
                every: self.incrementalNumber,
                hour: anchorHour,
                minute: anchorMinute
            )
        case .week:
            return .startOfWeek(
                every: self.incrementalNumber,
                weekday: self.selectedWeekday,
                hour: anchorHour,
                minute: anchorMinute
            )
        case .month:
            return .startOfMonth(
                every: self.incrementalNumber,
                hour: anchorHour,
                minute: anchorMinute
            )
        case .year:
            return .startOfYear(
                every: self.incrementalNumber,
                hour: anchorHour,
                minute: anchorMinute
            )
        }
        
    }
    
    private var scheduleStrategy: LocalNotificationScheduleStrategy? {
        
        switch self.selectedPattern {
        case .interval:
            return .interval(
                number: self.incrementalNumber,
                timeSpan: self.selectedTimeSpan
            )
        case .anchored:
            guard let anchoredRule else {
                return nil
            }
            return .anchored(anchoredRule)
        }
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.localNotificationService
            .permissionGrantedPublisher
            .receiveOnMain()
            .sink { [weak self] isGranted in
                self?.isPermissionGranted = isGranted
            }
            .store(in: &self.cancelBag)
        
        self.localNotificationService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] shouldPrompt in
                self?.shouldPromptForPermissions = shouldPrompt
            }
            .store(in: &self.cancelBag)
        
        self.viewLifecycleService
            .onDidBecomeActive
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.refreshNotifications()
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension DevLocalNotificationsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.localNotifications))
    }
    
}

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
    
    @Published var selectedAnchoredCadenceString: String? = LocalNotificationRecurrenceCadence.day.displayName
    @Published var selectedAnchoredBoundaryString: String? = LocalNotificationRecurrenceBoundary.start.displayName
    
    @Published var selectedCalendarCadenceString: String? = LocalNotificationRecurrenceCadence.week.displayName
    @Published var selectedCalendarMonthString: String? = LocalNotificationMonth.january.displayName
    @Published var selectedCalendarWeekdays: Set<LocalNotificationWeekday> = [.monday]
    
    @Published var incrementalNumberText: String = "1"
    @Published var anchorHourText: String = "8"
    @Published var anchorMinuteText: String = "0"
    @Published var calendarDayOfMonthText: String = "3"
    @Published var calendarYearDayOfMonthText: String = "1"
    
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
    
    var allAnchoredCadenceOptions: [String] {
        return LocalNotificationRecurrenceCadence.allCases.map(\.displayName)
    }
    
    var allAnchoredBoundaryOptions: [String] {
        return LocalNotificationRecurrenceBoundary.allCases.map(\.displayName)
    }
    
    var allCalendarCadenceOptions: [String] {
        return [
            LocalNotificationRecurrenceCadence.week,
            LocalNotificationRecurrenceCadence.month,
            LocalNotificationRecurrenceCadence.year
        ]
        .map(\.displayName)
    }
    
    var allCalendarMonthOptions: [String] {
        return LocalNotificationMonth.allCases.map(\.displayName)
    }
    
    var orderedWeekdays: [LocalNotificationWeekday] {
        return LocalNotificationWeekday.orderedByCalendar()
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
    
    var selectedAnchoredCadence: LocalNotificationRecurrenceCadence {
        
        let fallback = LocalNotificationRecurrenceCadence.day
        
        guard let selectedAnchoredCadenceString else {
            return fallback
        }
        
        return LocalNotificationRecurrenceCadence
            .allCases
            .first(where: { $0.displayName == selectedAnchoredCadenceString }) ?? fallback
        
    }
    
    var selectedAnchoredBoundary: LocalNotificationRecurrenceBoundary {
        
        let fallback = LocalNotificationRecurrenceBoundary.start
        
        guard let selectedAnchoredBoundaryString else {
            return fallback
        }
        
        return LocalNotificationRecurrenceBoundary
            .allCases
            .first(where: { $0.displayName == selectedAnchoredBoundaryString }) ?? fallback
        
    }
    
    var selectedCalendarCadence: LocalNotificationRecurrenceCadence {
        
        let fallback = LocalNotificationRecurrenceCadence.week
        
        guard let selectedCalendarCadenceString else {
            return fallback
        }
        
        return [
            LocalNotificationRecurrenceCadence.week,
            LocalNotificationRecurrenceCadence.month,
            LocalNotificationRecurrenceCadence.year
        ]
        .first(where: { $0.displayName == selectedCalendarCadenceString }) ?? fallback
        
    }
    
    var selectedCalendarMonth: LocalNotificationMonth {
        
        let fallback = LocalNotificationMonth.january
        
        guard let selectedCalendarMonthString else {
            return fallback
        }
        
        return LocalNotificationMonth
            .allCases
            .first(where: { $0.displayName == selectedCalendarMonthString }) ?? fallback
        
    }
    
    var selectedCalendarWeekdaysOrdered: [LocalNotificationWeekday] {
        
        let selected = self.selectedCalendarWeekdays
        
        return self.orderedWeekdays
            .filter { selected.contains($0) }
        
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
    
    var calendarDayOfMonth: Int? {
        return Int(self.calendarDayOfMonthText)
    }
    
    var calendarYearDayOfMonth: Int? {
        return Int(self.calendarYearDayOfMonthText)
    }
    
    var shouldShowIntervalControls: Bool {
        return self.selectedPattern == .interval
    }
    
    var shouldShowAnchoredControls: Bool {
        return self.selectedPattern == .anchored
    }
    
    var shouldShowAnchoredBoundaryControl: Bool {
        return self.selectedAnchoredCadence != .day
    }
    
    var shouldShowCalendarControls: Bool {
        return self.selectedPattern == .calendarType
    }
    
    var shouldShowCalendarWeeklyControls: Bool {
        return self.selectedPattern == .calendarType && self.selectedCalendarCadence == .week
    }
    
    var shouldShowCalendarMonthlyControls: Bool {
        return self.selectedPattern == .calendarType && self.selectedCalendarCadence == .month
    }
    
    var shouldShowCalendarYearlyControls: Bool {
        return self.selectedPattern == .calendarType && self.selectedCalendarCadence == .year
    }
    
    var isScheduleValid: Bool {
        
        guard self.incrementalNumber >= 1 else {
            return false
        }
        
        guard let hour = self.anchorHour,
              let minute = self.anchorMinute,
              (0...23).contains(hour),
              (0...59).contains(minute)
        else {
            return false
        }
        
        switch self.selectedPattern {
        case .interval:
            return true
            
        case .anchored:
            guard let anchoredRule else {
                return false
            }
            return anchoredRule.isValid(for: .anchored)
            
        case .calendarType:
            guard let calendarRule else {
                return false
            }
            return calendarRule.isValid(for: .calendarType)
        }
        
    }
    
    var schedulePreviewText: String {
        
        let timeLabel = self.formattedTimeLabel
        
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
            
            let cadence = self.selectedAnchoredCadence
            let cadenceLabel = cadence.displayName
            
            let anchorLabel: String
            
            if cadence == .day {
                anchorLabel = "daily"
            }
            else {
                anchorLabel = "\(self.selectedAnchoredBoundary.displayName.lowercased()) of \(cadenceLabel.lowercased())"
            }
            
            switch self.selectedMode {
            case .oneTime:
                return "Will fire on next \(anchorLabel) at \(timeLabel)"
            case .recurring:
                return "Will fire every \(self.incrementalNumber) \(cadenceLabel.lowercased())(s) at \(anchorLabel) \(timeLabel)"
            }
            
        case .calendarType:
            
            let descriptor: String
            
            switch self.selectedCalendarCadence {
            case .week:
                let labels = self.selectedCalendarWeekdaysOrdered
                    .map(\.shortDisplayName)
                    .joined(separator: ", ")
                descriptor = labels.isEmpty ? "selected weekdays" : labels
                
            case .month:
                descriptor = "day \(self.calendarDayOfMonthText)"
                
            case .year:
                descriptor = "\(self.selectedCalendarMonth.displayName) \(self.calendarYearDayOfMonthText)"
                
            case .day:
                descriptor = "day"
            }
            
            switch self.selectedMode {
            case .oneTime:
                return "Will fire on next \(descriptor) at \(timeLabel)"
            case .recurring:
                return "Will fire every \(self.incrementalNumber) \(self.selectedCalendarCadence.displayName.lowercased())(s) on \(descriptor) at \(timeLabel)"
            }
        }
        
    }
    
    var nextOccurrencesPreviewText: String {
        
        guard let recurrenceInput else {
            return ""
        }
        
        let previewDates = self.recurrenceCalculator.nextOccurrences(
            for: recurrenceInput.rule,
            pattern: recurrenceInput.pattern,
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
    
    func toggleCalendarWeekday(_ weekday: LocalNotificationWeekday) {
        
        if self.selectedCalendarWeekdays.contains(weekday) {
            self.selectedCalendarWeekdays.remove(weekday)
        }
        else {
            self.selectedCalendarWeekdays.insert(weekday)
        }
        
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
    
    private var formattedTimeLabel: String {
        
        let hour = Int(self.anchorHourText) ?? 0
        let minute = Int(self.anchorMinuteText) ?? 0
        return String(format: "%02d:%02d", hour, minute)
        
    }
    
    private var anchoredRule: LocalNotificationRecurrenceRule? {
        
        guard let hour = self.anchorHour,
              let minute = self.anchorMinute
        else {
            return nil
        }
        
        switch self.selectedAnchoredCadence {
        case .day:
            return .anchoredDaily(
                every: self.incrementalNumber,
                hour: hour,
                minute: minute
            )
            
        case .week,
                .month,
                .year:
            return .anchored(
                cadence: self.selectedAnchoredCadence,
                every: self.incrementalNumber,
                boundary: self.selectedAnchoredBoundary,
                hour: hour,
                minute: minute
            )
        }
        
    }
    
    private var calendarRule: LocalNotificationRecurrenceRule? {
        
        guard let hour = self.anchorHour,
              let minute = self.anchorMinute
        else {
            return nil
        }
        
        switch self.selectedCalendarCadence {
        case .week:
            return .calendarWeekly(
                every: self.incrementalNumber,
                weekdays: self.selectedCalendarWeekdaysOrdered,
                hour: hour,
                minute: minute
            )
            
        case .month:
            
            guard let dayOfMonth = self.calendarDayOfMonth,
                  (1...31).contains(dayOfMonth)
            else {
                return nil
            }
            
            return .calendarMonthly(
                every: self.incrementalNumber,
                dayOfMonth: dayOfMonth,
                hour: hour,
                minute: minute
            )
            
        case .year:
            
            guard let dayOfMonth = self.calendarYearDayOfMonth,
                  (1...31).contains(dayOfMonth)
            else {
                return nil
            }
            
            return .calendarYearly(
                every: self.incrementalNumber,
                month: self.selectedCalendarMonth.rawValue,
                dayOfMonth: dayOfMonth,
                hour: hour,
                minute: minute
            )
            
        case .day:
            return nil
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
            return .anchored(rule: anchoredRule)
            
        case .calendarType:
            guard let calendarRule else {
                return nil
            }
            return .calendarType(rule: calendarRule)
        }
        
    }
    
    private var recurrenceInput: (pattern: LocalNotificationSchedulePattern,
                                  rule: LocalNotificationRecurrenceRule)? {
        
        switch self.selectedPattern {
        case .interval:
            return nil
        case .anchored:
            guard let anchoredRule else {
                return nil
            }
            return (.anchored, anchoredRule)
        case .calendarType:
            guard let calendarRule else {
                return nil
            }
            return (.calendarType, calendarRule)
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

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
    
    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var refreshTask: Task<Void, Never>?
    private var scheduleTask: Task<Void, Never>?
    
    @Published var selectedModeString: String? = LocalNotificationScheduleMode.oneTime.displayName
    @Published var selectedTimeSpanString: String? = LocalNotificationTimeSpan.minute.displayName
    @Published var incrementalNumberText: String = "1"
    
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
    
    var allTimeSpanOptions: [String] {
        return LocalNotificationTimeSpan.allCases.map(\.displayName)
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
    
    var selectedTimeSpan: LocalNotificationTimeSpan {
        
        let fallback = LocalNotificationTimeSpan.minute
        
        guard let selectedTimeSpanString else {
            return fallback
        }
        
        return LocalNotificationTimeSpan
            .allCases
            .first(where: { $0.displayName == selectedTimeSpanString }) ?? fallback
        
    }
    
    var incrementalNumber: Int {
        
        let parsedNumber = Int(self.incrementalNumberText) ?? 0
        return max(parsedNumber, 0)
        
    }
    
    var isScheduleValid: Bool {
        return self.incrementalNumber >= 1
    }
    
    var schedulePreviewText: String {
        
        let unit = self.incrementalNumber == 1
        ? self.selectedTimeSpan.displayName.lowercased()
        : self.selectedTimeSpan.displayNamePlural.lowercased()
        
        switch self.selectedMode {
        case .oneTime:
            return "Will fire in \(self.incrementalNumber) \(unit)"
        case .recurring:
            return "Will fire every \(self.incrementalNumber) \(unit)"
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
                message: "incremental_number must be 1 or greater."
            )
            
            return
            
        }
        
        let mode = self.selectedMode
        let timeSpan = self.selectedTimeSpan
        let incrementalNumber = self.incrementalNumber
        
        let unit = incrementalNumber == 1
        ? timeSpan.displayName.lowercased()
        : timeSpan.displayNamePlural.lowercased()
        
        let title = mode == .oneTime
        ? "Scheduled Local Notification"
        : "Recurring Local Notification"
        
        let body = mode == .oneTime
        ? "Your local notification fired after \(incrementalNumber) \(unit)."
        : "Your local notification is repeating every \(incrementalNumber) \(unit)."
        
        let request = LocalNotificationScheduleRequest(
            incrementalNumber: incrementalNumber,
            timeSpan: timeSpan,
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

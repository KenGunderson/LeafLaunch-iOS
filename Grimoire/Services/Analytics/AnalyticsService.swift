//
//  AnalyticsService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Observation
import Amplitude
import AdSupport
import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics

final class AnalyticsService: AnalyticsServiceProtocol {

    internal let loggerName: String = "ANALYTICS_SERVICE"
    internal let loggerEmoji: String = "📀"

    private var amplitude: Amplitude?

    private(set) var environmentService: EnvironmentServiceProtocol
    private(set) var permissionService: PermissionsServiceProtocol

    private(set) var currentUserId = CurrentValueSubject<String?, Never>(nil)

    @Published private(set) var sessionEvents: [EventData] = []
    var sessionEventsPublisher: AnyPublisher<[EventData], Never> {
        return self.$sessionEvents.eraseToAnyPublisher()
    }

    private var currentIdfa: String = "00000000-0000-0000-0000-000000000000"
    private var cancelBag: CancelBag!

    init(environmentService: EnvironmentServiceProtocol,
         permissionService: PermissionsServiceProtocol) {

        self.environmentService = environmentService
        self.permissionService = permissionService

        self.logInit()
        self.sessionEvents = []

        bindSubscribers()

    }

    deinit {
        self.logDeinit()
    }

    private func bindSubscribers() {

        self.cancelBag = CancelBag()

        self.permissionService
            .appTrackingPermissionService
            .attStatusPublisher
            .receiveOnMain()
            .sink { [weak self] status in
                self?.updateAdvertisingIdentifierAndStatus(status ?? .notDetermined)
            }
            .store(in: &self.cancelBag)

        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] env in

                self?.log(message: "Environment: \(env?.displayName ?? "NIL")")

                self?.setRemoteAnalyticsCollectionEnabled(env == .production)

                guard env == .production else { return }

                FirebaseApp.configureIfNeeded()
                self?.setupAmplitude()
            }
            .store(in: &self.cancelBag)

    }

    private func setupAmplitude() {

        guard self.amplitude == nil else { return }

        self.amplitude = Amplitude.instance()
        self.amplitude?.initializeApiKey(Constants.Analytics.AMPLITUDE_KEY)
        self.amplitude?.defaultTracking = .initWithSessions(
            true,
            appLifecycles: true,
            deepLinks: true,
            screenViews: false
        )
        self.amplitude?.adSupportBlock = { [weak self] in
            return self?.currentIdfa ?? "00000000-0000-0000-0000-000000000000"
        }

    }

    // MARK: Public

    func identifyUser(_ userId: String?) {

        self.log(message: "identify: \(userId ?? "nil")")

        self.currentUserId.send(userId)

        // Remote Analytics

        if self.environmentService.environment == .production {

            self.amplitude?.setUserId(userId)

            FirebaseApp.configureIfNeeded()
            Analytics.setUserID(userId)
            Crashlytics.crashlytics().setUserID(userId ?? "")

        }

        // Logging

        self.log(message: "USER_ID: \(userId ?? "NIL")")

        let loggingEvent = EventData(
            name: "identify",
            properties: ["user_id": (userId != nil) ? userId! : "nil"]
        )

        sessionEvents.append(loggingEvent)

    }

    func setUserProperty(_ key: String,
                         value: String) {

        self.log(message: "user_property: [\(key): \(value)]")

        // Remote Analytics

        guard self.environmentService.environment == .production else { return }

        let identify = AMPIdentify()
        identify.set(key, value: value as NSString)
        self.amplitude?.identify(identify)

        FirebaseApp.configureIfNeeded()
        Analytics.setUserProperty(value, forName: key)

        // Logging

        self.log(message: "User property: \(key)\n METADATA:\nkey: \(key),\nvalue: \(value)")

        let loggingEvent = EventData(
            name: "user_property",
            properties: [key: value]
        )

        sessionEvents.append(loggingEvent)

    }

    func track(_ app: AppEvent) {
        track(event: app)
    }

    func track(screen: ScreenEvent) {
        track(event: screen)
    }

    func track(error: ErrorEvent) {
        track(event: error)
    }

    func clearSessionEvents() {
        self.sessionEvents = []
    }

    private func track(event: AnalyticsEvent) {

        let type = event.eventType
        let data = event.eventData

        let message = (data.properties != nil) ?
            "\(data.name): \(data.properties!)" :
            data.name

        var debugLogMessage = "Analytics event"

        switch type {
        case .app:

            debugLogMessage = "App: \(data.name)"

        case .screen:

            if let screenName = data.properties?["screen"] as? String {
                debugLogMessage = "Screen: \(screenName)"
            }
            else {
                debugLogMessage = "Screen event"
            }

        case .error:

            if let errorName = data.properties?["name"] as? String {
                debugLogMessage = "Error: \(errorName)"
            }
            else {
                debugLogMessage = "Error event"
            }

        }

        self.log(message: "\(type.displayName.uppercased()):\n\(message)\n\(debugLogMessage)")

        sessionEvents.append(data)

        guard self.environmentService.environment == .production else { return }

        self.amplitude?.logEvent(
            data.name,
            withEventProperties: data.properties
        )

        FirebaseApp.configureIfNeeded()

        Analytics.logEvent(
            data.name,
            parameters: data.properties
        )

        if case .error = type {
            recordCrashlyticsNonFatal(event: event)
        }

    }

    func logout() {

        self.log(message: "logout")
        self.currentUserId.send(nil)
        identifyUser(nil)

    }

    // MARK: Private

    private func setRemoteAnalyticsCollectionEnabled(_ isEnabled: Bool) {

        FirebaseApp.configureIfNeeded()
        Analytics.setAnalyticsCollectionEnabled(isEnabled)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(isEnabled)

    }

    private func recordCrashlyticsNonFatal(event: AnalyticsEvent) {

        guard let errorEvent = event as? ErrorEvent else { return }

        let error = errorEvent.error ?? NSError(
            domain: Bundle.main.bundleIdentifier ?? "com.grimoire.analytics",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: errorEvent
                    .eventData
                    .properties?["message"] as? String ?? "Tracked analytics error"
            ]
        )

        errorEvent
            .eventData
            .properties?
            .forEach { key, value in

                Crashlytics.crashlytics().setCustomValue(value, forKey: key)

            }

        Crashlytics.crashlytics().record(error: error)

    }

    private func updateAdvertisingIdentifierAndStatus(_ status: ATTStatus) {

        self.currentIdfa = ASIdentifierManager
            .shared()
            .advertisingIdentifier
            .uuidString

        // Amplitude: handled via `adSupportBlock` passed
        // in during SDK initialization

    }

}

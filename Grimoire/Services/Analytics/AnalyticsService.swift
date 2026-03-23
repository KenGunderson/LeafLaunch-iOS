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
import FactoryKit

final class AnalyticsService: AnalyticsServiceProtocol {
    
    internal let loggerName: String = "ANALYTICS_SERVICE"
    internal let loggerEmoji: String = "📀"
    
    private var amplitude: Amplitude?
    
    private(set) var environmentService: EnvironmentServiceProtocol
    private(set) var permissionService: PermissionsServiceProtocol
    @LazyInjected(\.impersonateService) private var impersonateService: ImpersonateServiceProtocol
    
    private(set) var currentUserId = CurrentValueSubject<String?, Never>(nil)
    
    @Published private(set) var sessionEvents: [EventData] = []
    var sessionEventsPublisher: AnyPublisher<[EventData], Never> {
        return self.$sessionEvents.eraseToAnyPublisher()
    }
    
    private var isImpersonating: Bool {
        return (self.impersonateService).isImpersonating
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
    
    func set(impersonateService: ImpersonateServiceProtocol) {
        self.impersonateService = impersonateService
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
                
                guard env == .production else { return }
                self?.setupAmplitude()
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func setupAmplitude() {

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
        
        guard !self.isImpersonating else { return }
                
        self.log(message: "identify: \(userId ?? "nil")")

        self.currentUserId.send(userId)
        
        // Amplitude

        self.amplitude?.setUserId(userId)
        
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
        
        guard !self.isImpersonating else { return }
        
        self.log(message: "user_property: [\(key): \(value)]")
        
        // Amplitude

        let identify = AMPIdentify()
        identify.set(key, value: value as NSString)
        self.amplitude?.identify(identify)

        // Logging
        
        self.log(message: "User property: \(key)\n METADATA:\nkey: \(key),\nvalue: \(value)")
    
        let loggingEvent = EventData(
            name: "user_property",
            properties: [key: value]
        )
        
        guard self.environmentService.environment == .production else { return }

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
        
        guard !self.isImpersonating else { return }
        
        sessionEvents.append(data)
        
        guard self.environmentService.environment == .production else { return }
        
        self.amplitude?.logEvent(
            data.name,
            withEventProperties: data.properties
        )
        
    }
    
    func logout() {
        
        self.log(message: "logout")
        self.currentUserId.send(nil)
        identifyUser(nil)
        
    }
    
    // MARK: Private
    
    private func updateAdvertisingIdentifierAndStatus(_ status: ATTStatus) {
                
        self.currentIdfa = ASIdentifierManager
            .shared()
            .advertisingIdentifier
            .uuidString
        
        // Amplitude: handled via `adSupportBlock` passed
        // in during SDK initialization
        
    }
    
}

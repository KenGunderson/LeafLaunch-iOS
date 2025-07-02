//
//  DevAnalyticsViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 10/19/24.
//

import OSLog
import SwiftUI
import Combine

final class DevAnalyticsViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    enum DisplayType: String, CaseIterable {
        
        case logs
        case analytics
        case api
        
    }
    
    private(set) var analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published var events: [EventData] = []
    
    @Published var selectedDisplayType: DisplayType = .logs
    @Published var selectedDisplayTypeString: String?
    
    @Published var selectedOSLogType: OSLogType?
    @Published var selectedOSLogTypeString: String?
        
    var logEvents: [LogEvent] {
        
        if let selectedOSLogType {
            
            return loggedEvents
                .filter { $0.level == selectedOSLogType}
            
        }
        
        return loggedEvents
        
    }
    
    var allOSLogOptions: [String] {
        return OSLogType.allOptions()
    }
    
    var allAPILogResponses: [APILogResponse] {
        return apiLogResponses
    }
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
        self.selectedDisplayTypeString = self.selectedDisplayType.rawValue.capitalized
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func selectDisplayTypeFromString(_ type: String?) {
        
        if let type,
           let displayType = DisplayType(rawValue: type.lowercased()) {
            
            withAnimation(.smooth) {
                self.selectedDisplayType = displayType
            }
            
        }
        
    }
    
    func selectOSLogTypeFromString(_ type: String?) {
    
        guard let type else {
            
            self.selectedOSLogType = nil
            return
            
        }
        
        let logType: OSLogType? = switch type.lowercased() {
        case "default": .default
        case "info": .info
        case "debug": .debug
        case "error": .error
        case "fault": .fault
        default: nil
        }
        
        self.selectedOSLogType = logType
        
    }
    
    @MainActor
    func handleDeeplink(url: URL) {
        
        globalTabBarNavigationService
            .currentNavigationService()
            .dismissFullScreenCover()
        
        UIApplication.shared.open(url)
        
    }

    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.analyticsService
            .sessionEventsPublisher
            .receiveOnMain()
            .sink { [weak self] events in
                self?.events = events
            }
            .store(in: &cancelBag)
        
        self.$selectedDisplayTypeString
            .receiveOnMain()
            .sink { [weak self] type in
                self?.selectDisplayTypeFromString(type)
            }
            .store(in: &cancelBag)
        
        self.$selectedOSLogTypeString
            .receiveOnMain()
            .sink { [weak self] type in
                self?.selectOSLogTypeFromString(type)
            }
            .store(in: &cancelBag)
        
    }
    
}

extension DevAnalyticsViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.analytics))
    }
    
}

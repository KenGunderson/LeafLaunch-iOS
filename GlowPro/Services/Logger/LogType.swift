//
//  LogType.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/17/24.
//

import OSLog
import SwiftUI

enum GPLogger {
    
    enum ViewModel: String {
        
        case root
        case welcome
        case login
        case signUp
        case main
        case onboarding
        case home
        case whatsNew
        
        case tab1
        case tab2
        case tab3
        case tab4
        
        fileprivate var displayName: String {
            
            let viewModelString = "View Model"
            let styledText = self.rawValue.convertNamingStyle(from: .camelCase, to: .sentenceCase)
            return "[\(styledText) \(viewModelString)]".uppercased()
            
        }
        
        fileprivate var icon: String {
            
            switch self {
            case .root: return "🌳"
            case .welcome: return "✨"
            case .login: return "🔐"
            case .signUp: return "📝"
            case .main: return "🏁"
            case .onboarding: return "🎟️"
            case .home: return "🏠"
            case .whatsNew: return "🆕"
            case .tab1: return "🔹"
            case .tab2: return "🔺"
            case .tab3: return "◯"
            case .tab4: return "×"
            }
            
        }

        fileprivate var logger: Logger {
            
            switch self {
            case .root: return Logger.root
            case .welcome: return Logger.welcome
            case .login: return Logger.login
            case .signUp: return Logger.signUp
            case .main: return Logger.main
            case .onboarding: return Logger.onboarding
            case .home: return Logger.home
            case .whatsNew: return Logger.whatsNew
            case .tab1: return Logger.tab1
            case .tab2: return Logger.tab2
            case .tab3: return Logger.tab3
            case .tab4: return Logger.tab4
            }
            
        }
        
    }
    
    enum Service: String {
        
        case auth
        case alert
        case firebase
        case deeplink
        case impersonate
        case API
        case analyticsAPI
        case webSocket
        case mockAPI
        case appDelegate
        case pushNotification
        case lifecycle
        case analytics
        case widget
        case environment
        case connectivity
        case launch
        case permissions
        case userDefaults
        case navigation
        
        var displayName: String {
            
            let serviceString = "Service"
            
            var styledText = self.rawValue.convertNamingStyle(from: .camelCase, to: .sentenceCase)
            
            switch self {
            case .API: styledText = "API"
            case .analyticsAPI: styledText = "ANALYTICS API"
            default: break
            }
            
            return "[\(styledText) \(serviceString)]".uppercased()
            
        }
        
        var icon: String {
            
            switch self {
            case .auth: return "🔑"
            case .alert: return "🚨"
            case .firebase: return "🔥"
            case .deeplink: return "🔗"
            case .impersonate: return "🕵️‍♂️"
            case .API: return "🌐"
            case .analyticsAPI: return "🌐"
            case .webSocket: return "🌐"
            case .mockAPI: return "🌐"
            case .appDelegate: return "🗂️"
            case .pushNotification: return "📬"
            case .lifecycle: return "♻️"
            case .analytics: return "🎥"
            case .widget: return "⌚️"
            case .environment: return "🌍"
            case .connectivity: return "📡"
            case .launch: return "🚀"
            case .permissions: return "📜"
            case .userDefaults: return "🗄️"
            case .navigation: return "🧭"
            }
            
        }
        
        var logger: Logger {
            
            switch self {
            case .auth: return Logger.auth
            case .alert: return Logger.alert
            case .firebase: return Logger.firebase
            case .deeplink: return Logger.deeplink
            case .impersonate: return Logger.impersonate
            case .API: return Logger.API
            case .analyticsAPI: return Logger.analyticsAPI
            case .webSocket: return Logger.webSocket
            case .mockAPI: return Logger.mockAPI
            case .appDelegate: return Logger.appDelegate
            case .pushNotification: return Logger.pushNotification
            case .lifecycle: return Logger.lifecycle
            case .analytics: return Logger.analytics
            case .widget: return Logger.widget
            case .environment: return Logger.environment
            case .connectivity: return Logger.connectivity
            case .launch: return Logger.launch
            case .permissions: return Logger.permissions
            case .userDefaults: return Logger.userDefaults
            case .navigation: return Logger.navigation
            }
            
        }
        
    }
    
    case viewModel(ViewModel)
    case service(Service)
    
    fileprivate var displayName: String {
        
        switch self {
        case .viewModel(let model): return model.displayName
        case .service(let service): return service.displayName
        }
        
    }
    
    fileprivate var icon: String {
        
        switch self {
        case .viewModel(let model): return model.icon
        case .service(let service): return service.icon
        }
        
    }
    
    var logger: Logger {
        
        switch self {
        case .viewModel(let model): return model.logger
        case .service(let service): return service.logger
        }
        
    }
    
    func logInit() {
        debugMessage("Starting")
    }
    
    func logDeinit() {
        debugMessage("Deinitialized")
    }
    
    func debugMessage(level: OSLogType = .debug,
                      _ message: String) {
        
        let repeatedIcon = String(
            repeating: self.icon,
            count: 5
        )
        
        let formattedString = "\(repeatedIcon) \(self.displayName) \(message)".uppercased()
        
        self.logger.log(
            level: level,
            "\(formattedString)"
        )
        
        loggedEvents
            .append(.init(
                message: message,
                source: self.displayName,
                level: level,
                emoji: self.icon
            ))
        
    }
    
    func prettyDebugMessage(level: OSLogType = .debug,
                            _ message: String) {
        
        let repeatedIcon = String(
            repeating: self.icon,
            count: 5
        )
        
        self.logger
            .prettyLogging(
                level: level,
                title: "\(repeatedIcon) \(self.displayName)",
                message: message
            )
        
        loggedEvents
            .append(.init(
                message: message,
                source: self.displayName,
                level: level,
                emoji: self.icon
            ))
        
    }
    
    func error(title: String,
               message: String) {
        
        let repeatedIcon = String(
            repeating: self.icon,
            count: 5
        )
        
        let formattedString = "\(repeatedIcon) \(self.displayName) \(message)".uppercased()
        
        self.logger.prettyLogging(
            level: .error,
            title: "\(title.uppercased())",
            message: formattedString
        )
        
        loggedEvents
            .append(.init(
                title: title,
                message: message,
                source: self.displayName,
                level: .error,
                emoji: self.icon
            ))
        
    }
    
}

extension OSLogType {
    
    static func allOptions() -> [String] {
        return [
            "Default",
            "Info",
            "Debug",
            "Error",
            "Fault"
        ]
    }
    
    func displayName() -> String {
        
        switch self {
        case .default: return "Default"
        case .info: return "Info"
        case .debug: return "Debug"
        case .error: return "Error"
        case .fault: return "Fault"
        default: return "Unknown"
        }
        
    }
    
    func color() -> Color {
        
        switch self {
        case .default: return .primary
        case .info: return .blue
        case .debug: return .green
        case .error: return .red
        case .fault: return .orange
        default: return .gray
        }
        
    }
    
    func systemImage() -> String {

        switch self {
        case .default: return "dot.circle"
        case .info: return "info.circle"
        case .debug: return "wrench.and.screwdriver"
        case .error: return "xmark.octagon"
        case .fault: return "exclamationmark.triangle"
        default: return "questionmark.circle"
        }
        
    }
    
}

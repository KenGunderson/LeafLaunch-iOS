//
//  LoggerService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import SwiftUI
import OSLog

public protocol Loggable: Sendable {
    
    nonisolated var loggerName: String { get }
    nonisolated var loggerEmoji: String { get }
    nonisolated var logger: Logger { get }
    
}

public extension Loggable {
    
    nonisolated var logger: Logger {
        
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.your.app",
            category: loggerName
        )
        
    }
    
    nonisolated fileprivate func formattedString(title: String? = nil,
                                                 message: String,
                                                 level: OSLogType,
                                                 file: StaticString,
                                                 function: StaticString,
                                                 line: UInt) -> String {
        
        let icons = String(repeating: loggerEmoji, count: 5)
        let header = "\(icons) [\(loggerName.uppercased())]"
        
        let fileURLPath = URL(fileURLWithPath: "\(file)").pathComponents
        let formattedFile = fileURLPath.suffix(3).joined(separator: "/")
        
        var components = [header]
        
        if let title = title {
            components.append("[Title]: \(title)")
        }
        components.append("[Message]: \(message)")
        components.append("[File]: \(formattedFile) [Function]: \(function) [Line]: \(line)")
        
        return components.joined(separator: "\n")
        
    }

    nonisolated func logInit(file: StaticString = #file,
                             function: StaticString = #function,
                             line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "Init",
            level: .info,
            file: file,
            function: function,
            line: line
        )
        
        LoggedEventsStore.shared.append(.init(
            title: "Init",
            message: formattedString,
            source: loggerName,
            level: .info,
            emoji: loggerEmoji
        ))
        
        logger.log(
            level: .info,
            "\(formattedString)"
        )
        
    }

    nonisolated func logDeinit(file: StaticString = #file,
                               function: StaticString = #function,
                               line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "Deinit",
            level: .info,
            file: file,
            function: function,
            line: line
        )
        
        LoggedEventsStore.shared.append(.init(
            title: "Deinit",
            message: formattedString,
            source: loggerName,
            level: .info,
            emoji: loggerEmoji
        ))
        
        logger.log(
            level: .info,
            "\(formattedString)"
        )
        
    }

    nonisolated func log(
        level: OSLogType = .debug,
        message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line) {
            
            let formattedString = formattedString(
                message: message,
                level: level,
                file: file,
                function: function,
                line: line
            )
            
            LoggedEventsStore.shared.append(.init(
                title: "Log",
                message: formattedString,
                source: loggerName,
                level: level,
                emoji: loggerEmoji
            ))
            
            logger.log(
                level: level,
                "\(formattedString)"
            )
            
    }

    nonisolated func logError(title: String? = nil,
                              message: String,
                              file: StaticString = #file,
                              function: StaticString = #function,
                              line: UInt = #line) {
        
        let formattedString = formattedString(
            title: title,
            message: message,
            level: .error,
            file: file,
            function: function,
            line: line
        )
        
        LoggedEventsStore.shared.append(.init(
            title: "Error",
            message: formattedString,
            source: loggerName,
            level: .error,
            emoji: loggerEmoji
        ))
        
        logger.log(
            level: .error,
            "\(formattedString)"
        )
        
    }
    
}

//
//  LoggerService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import SwiftUI
import OSLog

public protocol Loggable {
    
    var loggerName: String { get }
    var loggerEmoji: String { get }
    var logger: Logger { get }
    
}

public extension Loggable {
    
    var logger: Logger {
        
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.your.app",
            category: loggerName
        )
        
    }
    
    fileprivate func formattedString(title: String? = nil,
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

    func logInit(file: StaticString = #file,
                 function: StaticString = #function,
                 line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "Init",
            level: .info,
            file: file,
            function: function,
            line: line
        )
        
        loggedEvents.append(.init(
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

    func logDeinit(file: StaticString = #file,
                   function: StaticString = #function,
                   line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "Deinit",
            level: .info,
            file: file,
            function: function,
            line: line
        )
        
        loggedEvents.append(.init(
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

    func log(
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
            
            loggedEvents.append(.init(
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

    func logError(title: String? = nil,
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
        
        loggedEvents.append(.init(
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

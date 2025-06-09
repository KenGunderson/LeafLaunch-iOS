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
    
    fileprivate func formattedString(title: String = "Log",
                                     message: String,
                                     level: OSLogType,
                                     file: StaticString,
                                     function: StaticString,
                                     line: UInt) -> String {
        
        let icons = String(repeating: loggerEmoji, count: 5)
        let header = "\(icons) \(loggerName.uppercased())"
        
        let fileURLPath = URL(fileURLWithPath: "\(file)").pathComponents
        let formattedFile = fileURLPath.suffix(4).joined(separator: "/")
                
        let formattedString = """
        \(header)
        [Title]: \(title)
        [Message]: \(message)
        [File]: \(formattedFile)
        [Function]: \(function)
        [Line]: \(line)
        """
        
        return formattedString
        
    }

    func logInit(file: StaticString = #file,
                 function: StaticString = #function,
                 line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "INIT",
            level: .info,
            file: file,
            function: function,
            line: line
        )
        
        logger.log(
            level: .info,
            "\(formattedString)"
        )
        
    }

    func logDeinit(file: StaticString = #file,
                   function: StaticString = #function,
                   line: UInt = #line) {
        
        let formattedString = formattedString(
            message: "DE-INIT",
            level: .info,
            file: file,
            function: function,
            line: line
        )
        
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
            title: title ?? "Log",
            message: message,
            level: .error,
            file: file,
            function: function,
            line: line
        )
        
        logger.log(
            level: .error,
            "\(formattedString)"
        )
        
    }
    
}

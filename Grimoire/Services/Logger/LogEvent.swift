//
//  LogEvent.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 10/20/24.
//

import Foundation
import OSLog

public struct LogEvent: Equatable, Sendable {
    
    let id: String = UUID().uuidString
    let createdAt: Date = Date()
    
    let title: String
    let message: String
    let source: String
    let level: OSLogType
    let emoji: String?
    
    init(title: String = "Log Event",
         message: String,
         source: String,
         level: OSLogType = .debug,
         emoji: String? = nil) {
        
        self.title = title
        self.message = message
        self.source = source
        self.level = level
        self.emoji = emoji
        
    }
    
}

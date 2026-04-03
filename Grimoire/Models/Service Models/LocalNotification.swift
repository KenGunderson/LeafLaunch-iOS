//
//  LocalNotificationScheduleMode.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

import UserNotifications

enum LocalNotificationScheduleMode: String, CaseIterable, Hashable, Sendable {
    
    case oneTime
    case recurring
    
    var displayName: String {
        switch self {
        case .oneTime: return "One Time"
        case .recurring: return "Recurring"
        }
    }
    
}

enum LocalNotificationTimeSpan: String, CaseIterable, Hashable, Sendable {
    
    case minute
    case hour
    case day
    case week
    
    var displayName: String {
        switch self {
        case .minute: return "Minute"
        case .hour: return "Hour"
        case .day: return "Day"
        case .week: return "Week"
        }
    }
    
    var displayNamePlural: String {
        return "\(self.displayName)s"
    }
    
    var secondsPerUnit: TimeInterval {
        switch self {
        case .minute: return 60
        case .hour: return 3600
        case .day: return 86_400
        case .week: return 604_800
        }
    }
    
}

struct LocalNotificationScheduleRequest: Sendable {
    
    let incrementalNumber: Int
    let timeSpan: LocalNotificationTimeSpan
    let mode: LocalNotificationScheduleMode
    let title: String
    let body: String
    
    var intervalSeconds: TimeInterval {
        return Double(self.incrementalNumber) * self.timeSpan.secondsPerUnit
    }
    
    var triggerIntervalSeconds: TimeInterval {
        
        if self.mode == .recurring {
            return max(self.intervalSeconds, 60)
        }
        
        return max(self.intervalSeconds, 1)
        
    }
    
}

struct LocalNotificationSnapshotItem: Identifiable, Sendable {
    
    enum Category: String, Sendable {
        case planned
        case incoming
    }
    
    let id: String
    let title: String
    let body: String
    let category: Category
    let date: Date?
    let isRepeating: Bool
    let relativeDescription: String
    
}

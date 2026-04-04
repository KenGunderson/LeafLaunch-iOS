//
//  LocalNotificationScheduleStrategy.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

enum LocalNotificationScheduleStrategy: Hashable, Sendable {
    
    case interval(number: Int,
                  timeSpan: LocalNotificationTimeSpan)
    
    case anchored(rule: LocalNotificationRecurrenceRule)
    case calendarType(rule: LocalNotificationRecurrenceRule)
    
    var pattern: LocalNotificationSchedulePattern {
        switch self {
        case .interval: return .interval
        case .anchored: return .anchored
        case .calendarType: return .calendarType
        }
    }
    
    var recurrenceRule: LocalNotificationRecurrenceRule? {
        switch self {
        case .interval:
            return nil
        case .anchored(let rule):
            return rule
        case .calendarType(let rule):
            return rule
        }
    }
    
}

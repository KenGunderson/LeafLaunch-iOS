//
//  LocalNotificationScheduleStrategy.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

enum LocalNotificationScheduleStrategy: Hashable, Sendable {
    
    case interval(number: Int,
                  timeSpan: LocalNotificationTimeSpan)
    
    case anchored(LocalNotificationRecurrenceRule)
    
    var pattern: LocalNotificationSchedulePattern {
        switch self {
        case .interval: return .interval
        case .anchored: return .anchored
        }
    }
    
}

//
//  LocalNotificationSchedulePattern.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

enum LocalNotificationSchedulePattern: String,
                                       CaseIterable,
                                       Hashable,
                                       Sendable {
    
    case interval
    case anchored
    case calendarType
    
    var displayName: String {
        switch self {
        case .interval: return "Interval"
        case .anchored: return "Anchored"
        case .calendarType: return "Calendar Type"
        }
    }
    
}

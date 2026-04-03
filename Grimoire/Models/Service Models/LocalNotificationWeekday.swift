//
//  LocalNotificationWeekday.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

enum LocalNotificationWeekday: Int, CaseIterable, Hashable, Sendable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
}

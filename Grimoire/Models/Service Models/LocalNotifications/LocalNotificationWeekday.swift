//
//  LocalNotificationWeekday.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

enum LocalNotificationWeekday: Int,
                               CaseIterable,
                               Hashable,
                               Sendable {
    
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
    
    var shortDisplayName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    static func orderedByCalendar(_ calendar: Calendar = .autoupdatingCurrent) -> [LocalNotificationWeekday] {
        
        let firstWeekday = calendar.firstWeekday
        
        return Self.allCases.sorted { lhs, rhs in
            let lhsOffset = (lhs.rawValue - firstWeekday + 7) % 7
            let rhsOffset = (rhs.rawValue - firstWeekday + 7) % 7
            return lhsOffset < rhsOffset
        }
        
    }
    
}

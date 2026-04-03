//
//  LocalNotificationRecurrenceCadence.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

enum LocalNotificationRecurrenceCadence: String, CaseIterable, Hashable, Sendable {
    
    case day
    case week
    case month
    case year
    
    var displayName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
    
}

//
//  LocalNotificationCalendarSelector.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

enum LocalNotificationCalendarSelector: Hashable, Sendable {
    
    case weekly(weekdays: [LocalNotificationWeekday])
    case monthly(dayOfMonth: Int)
    case yearly(month: Int,
                dayOfMonth: Int)
    
}

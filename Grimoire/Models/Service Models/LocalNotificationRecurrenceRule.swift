//
//  LocalNotificationRecurrenceRule.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

struct LocalNotificationRecurrenceRule: Hashable, Sendable {
    
    let cadence: LocalNotificationRecurrenceCadence
    let interval: Int
    let hour: Int
    let minute: Int
    let weekday: LocalNotificationWeekday?
    let dayOfMonth: Int?
    let month: Int?
    
    init(cadence: LocalNotificationRecurrenceCadence,
         interval: Int,
         hour: Int,
         minute: Int = 0,
         weekday: LocalNotificationWeekday? = nil,
         dayOfMonth: Int? = nil,
         month: Int? = nil) {
        
        self.cadence = cadence
        self.interval = max(interval, 1)
        self.hour = min(max(hour, 0), 23)
        self.minute = min(max(minute, 0), 59)
        self.weekday = weekday
        self.dayOfMonth = dayOfMonth
        self.month = month
        
    }
    
    var isValid: Bool {
        
        guard self.interval >= 1 else { return false }
        guard (0...23).contains(self.hour) else { return false }
        guard (0...59).contains(self.minute) else { return false }
        
        switch self.cadence {
        case .day: return true
        case .week: return self.weekday != nil
        case .month: return true
        case .year: return true
        }
        
    }
    
    static func startOfDay(every interval: Int,
                           hour: Int,
                           minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .day,
            interval: interval,
            hour: hour,
            minute: minute
        )
        
    }
    
    static func startOfWeek(every interval: Int,
                            weekday: LocalNotificationWeekday,
                            hour: Int,
                            minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .week,
            interval: interval,
            hour: hour,
            minute: minute,
            weekday: weekday
        )
        
    }
    
    static func startOfMonth(every interval: Int,
                             hour: Int,
                             minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .month,
            interval: interval,
            hour: hour,
            minute: minute,
            dayOfMonth: 1
        )
        
    }
    
    static func endOfMonth(every interval: Int,
                           hour: Int,
                           minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .month,
            interval: interval,
            hour: hour,
            minute: minute,
            dayOfMonth: 31
        )
        
    }
    
    static func startOfYear(every interval: Int,
                            hour: Int,
                            minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .year,
            interval: interval,
            hour: hour,
            minute: minute,
            dayOfMonth: 1,
            month: 1
        )
        
    }
    
    static func endOfYear(every interval: Int,
                          hour: Int,
                          minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .year,
            interval: interval,
            hour: hour,
            minute: minute,
            dayOfMonth: 31,
            month: 12
        )
        
    }
    
}

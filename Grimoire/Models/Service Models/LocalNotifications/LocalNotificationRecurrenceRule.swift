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
    let anchoredBoundary: LocalNotificationRecurrenceBoundary?
    let calendarSelector: LocalNotificationCalendarSelector?
    
    init(cadence: LocalNotificationRecurrenceCadence,
         interval: Int,
         hour: Int,
         minute: Int = 0,
         anchoredBoundary: LocalNotificationRecurrenceBoundary? = nil,
         calendarSelector: LocalNotificationCalendarSelector? = nil) {
        
        self.cadence = cadence
        self.interval = interval
        self.hour = hour
        self.minute = minute
        self.anchoredBoundary = anchoredBoundary
        self.calendarSelector = calendarSelector
        
    }
    
    var normalizedWeekdays: [LocalNotificationWeekday] {
        
        guard case .weekly(let weekdays) = self.calendarSelector else {
            return []
        }
        
        return Array(Set(weekdays))
            .sorted { $0.rawValue < $1.rawValue }
        
    }
    
    func isValid(for pattern: LocalNotificationSchedulePattern) -> Bool {
        
        guard self.interval >= 1 else { return false }
        guard (0...23).contains(self.hour) else { return false }
        guard (0...59).contains(self.minute) else { return false }
        
        switch pattern {
        case .interval:
            return false
            
        case .anchored:
            return self.isValidAnchored
            
        case .calendarType:
            return self.isValidCalendarType
        }
        
    }
    
    private var isValidAnchored: Bool {
        
        guard self.calendarSelector == nil else { return false }
        
        switch self.cadence {
        case .day:
            return self.anchoredBoundary == nil
            
        case .week,
                .month,
                .year:
            return self.anchoredBoundary != nil
        }
        
    }
    
    private var isValidCalendarType: Bool {
        
        guard self.anchoredBoundary == nil else { return false }
        
        switch (self.cadence, self.calendarSelector) {
        case (.week, .weekly(let weekdays)):
            return !weekdays.isEmpty
            
        case (.month, .monthly(let dayOfMonth)):
            return (1...31).contains(dayOfMonth)
            
        case (.year, .yearly(let month, let dayOfMonth)):
            return (1...12).contains(month)
            && (1...31).contains(dayOfMonth)
            
        default:
            return false
        }
        
    }
    
}

extension LocalNotificationRecurrenceRule {
    
    static func anchoredDaily(every interval: Int,
                              hour: Int,
                              minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .day,
            interval: interval,
            hour: hour,
            minute: minute,
            anchoredBoundary: nil,
            calendarSelector: nil
        )
        
    }
    
    static func anchored(cadence: LocalNotificationRecurrenceCadence,
                         every interval: Int,
                         boundary: LocalNotificationRecurrenceBoundary,
                         hour: Int,
                         minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: cadence,
            interval: interval,
            hour: hour,
            minute: minute,
            anchoredBoundary: boundary,
            calendarSelector: nil
        )
        
    }
    
    static func calendarWeekly(every interval: Int,
                               weekdays: [LocalNotificationWeekday],
                               hour: Int,
                               minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .week,
            interval: interval,
            hour: hour,
            minute: minute,
            anchoredBoundary: nil,
            calendarSelector: .weekly(weekdays: weekdays)
        )
        
    }
    
    static func calendarMonthly(every interval: Int,
                                dayOfMonth: Int,
                                hour: Int,
                                minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .month,
            interval: interval,
            hour: hour,
            minute: minute,
            anchoredBoundary: nil,
            calendarSelector: .monthly(dayOfMonth: dayOfMonth)
        )
        
    }
    
    static func calendarYearly(every interval: Int,
                               month: Int,
                               dayOfMonth: Int,
                               hour: Int,
                               minute: Int = 0) -> LocalNotificationRecurrenceRule {
        
        return LocalNotificationRecurrenceRule(
            cadence: .year,
            interval: interval,
            hour: hour,
            minute: minute,
            anchoredBoundary: nil,
            calendarSelector: .yearly(
                month: month,
                dayOfMonth: dayOfMonth
            )
        )
        
    }
    
}

extension LocalNotificationRecurrenceRule {
    
    static func startOfDay(every interval: Int,
                           hour: Int,
                           minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchoredDaily(
            every: interval,
            hour: hour,
            minute: minute
        )
    }
    
    static func startOfWeek(every interval: Int,
                            hour: Int,
                            minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchored(
            cadence: .week,
            every: interval,
            boundary: .start,
            hour: hour,
            minute: minute
        )
    }
    
    static func endOfWeek(every interval: Int,
                          hour: Int,
                          minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchored(
            cadence: .week,
            every: interval,
            boundary: .end,
            hour: hour,
            minute: minute
        )
    }
    
    static func startOfMonth(every interval: Int,
                             hour: Int,
                             minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchored(
            cadence: .month,
            every: interval,
            boundary: .start,
            hour: hour,
            minute: minute
        )
    }
    
    static func endOfMonth(every interval: Int,
                           hour: Int,
                           minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchored(
            cadence: .month,
            every: interval,
            boundary: .end,
            hour: hour,
            minute: minute
        )
    }
    
    static func startOfYear(every interval: Int,
                            hour: Int,
                            minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchored(
            cadence: .year,
            every: interval,
            boundary: .start,
            hour: hour,
            minute: minute
        )
    }
    
    static func endOfYear(every interval: Int,
                          hour: Int,
                          minute: Int = 0) -> LocalNotificationRecurrenceRule {
        return self.anchored(
            cadence: .year,
            every: interval,
            boundary: .end,
            hour: hour,
            minute: minute
        )
    }
    
}

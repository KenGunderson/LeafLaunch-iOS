//
//  LocalNotificationRecurrenceCalculator.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

struct LocalNotificationRecurrenceCalculator {
    
    func nextOccurrence(for rule: LocalNotificationRecurrenceRule,
                        after referenceDate: Date,
                        calendar: Calendar = .autoupdatingCurrent) -> Date? {
        
        guard rule.isValid else { return nil }
        
        switch rule.cadence {
        case .day:
            return nextDailyOccurrence(for: rule, after: referenceDate, calendar: calendar)
        case .week:
            return nextWeeklyOccurrence(for: rule, after: referenceDate, calendar: calendar)
        case .month:
            return nextMonthlyOccurrence(for: rule, after: referenceDate, calendar: calendar)
        case .year:
            return nextYearlyOccurrence(for: rule, after: referenceDate, calendar: calendar)
        }
        
    }
    
    func nextOccurrenceAfterPrevious(for rule: LocalNotificationRecurrenceRule,
                                     previousOccurrence: Date,
                                     calendar: Calendar = .autoupdatingCurrent) -> Date? {
        
        guard rule.isValid else { return nil }
        
        switch rule.cadence {
        case .day:
            return calendar.date(byAdding: .day, value: rule.interval, to: previousOccurrence)
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: rule.interval, to: previousOccurrence)
        case .month:
            
            guard let nextBase = calendar.date(byAdding: .month, value: rule.interval, to: previousOccurrence) else {
                return nil
            }
            
            return monthlyDate(
                for: rule,
                in: nextBase,
                calendar: calendar
            )
        
        case .year:
            
            guard let nextBase = calendar.date(byAdding: .year, value: rule.interval, to: previousOccurrence) else {
                return nil
            }
            
            return yearlyDate(
                for: rule,
                in: nextBase,
                calendar: calendar
            )
        }
        
    }
    
    func nextOccurrences(for rule: LocalNotificationRecurrenceRule,
                         after referenceDate: Date,
                         count: Int,
                         calendar: Calendar = .autoupdatingCurrent) -> [Date] {
        
        guard count > 0 else { return [] }
        
        var dates: [Date] = []
        var cursor = referenceDate
        
        while dates.count < count {
            
            guard let next = dates.isEmpty
                    ? self.nextOccurrence(for: rule, after: cursor, calendar: calendar)
                    : self.nextOccurrenceAfterPrevious(for: rule, previousOccurrence: dates[dates.count - 1], calendar: calendar)
            else {
                break
            }
            
            if next > cursor {
                dates.append(next)
                cursor = next
            }
            else {
                break
            }
            
        }
        
        return dates
        
    }
    
    func supportsRepeatingCalendarTrigger(for rule: LocalNotificationRecurrenceRule) -> Bool {
        
        switch rule.cadence {
        case .day:
            return true
        case .week:
            return rule.weekday != nil
        case .month:
            return (rule.dayOfMonth ?? 1) <= 28
        case .year:
            return true
        }
        
    }
    
    func repeatingDateComponents(for rule: LocalNotificationRecurrenceRule) -> DateComponents? {
        
        guard self.supportsRepeatingCalendarTrigger(for: rule) else {
            return nil
        }
        
        var components = DateComponents()
        components.hour = rule.hour
        components.minute = rule.minute
        components.second = 0
        
        switch rule.cadence {
        case .day:
            return components
        case .week:
            components.weekday = rule.weekday?.rawValue
            return components
        case .month:
            components.day = rule.dayOfMonth ?? 1
            return components
        case .year:
            components.day = rule.dayOfMonth ?? 1
            components.month = rule.month ?? 1
            return components
        }
        
    }
    
    private func nextDailyOccurrence(for rule: LocalNotificationRecurrenceRule,
                                     after referenceDate: Date,
                                     calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = rule.hour
        components.minute = rule.minute
        components.second = 0
        
        guard let todayAtAnchor = calendar.date(from: components) else {
            return nil
        }
        
        if todayAtAnchor > referenceDate {
            return todayAtAnchor
        }
        
        return calendar.date(byAdding: .day, value: 1, to: todayAtAnchor)
        
    }
    
    private func nextWeeklyOccurrence(for rule: LocalNotificationRecurrenceRule,
                                      after referenceDate: Date,
                                      calendar: Calendar) -> Date? {
        
        guard let weekday = rule.weekday else { return nil }
        
        var components = DateComponents()
        components.weekday = weekday.rawValue
        components.hour = rule.hour
        components.minute = rule.minute
        components.second = 0
        
        return calendar.nextDate(
            after: referenceDate,
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
        
    }
    
    private func nextMonthlyOccurrence(for rule: LocalNotificationRecurrenceRule,
                                       after referenceDate: Date,
                                       calendar: Calendar) -> Date? {
        
        guard let thisMonth = self.monthlyDate(for: rule, in: referenceDate, calendar: calendar) else {
            return nil
        }
        
        if thisMonth > referenceDate {
            return thisMonth
        }
        
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: referenceDate) else {
            return nil
        }
        
        return self.monthlyDate(for: rule, in: nextMonth, calendar: calendar)
        
    }
    
    private func nextYearlyOccurrence(for rule: LocalNotificationRecurrenceRule,
                                      after referenceDate: Date,
                                      calendar: Calendar) -> Date? {
        
        guard let thisYear = self.yearlyDate(for: rule, in: referenceDate, calendar: calendar) else {
            return nil
        }
        
        if thisYear > referenceDate {
            return thisYear
        }
        
        guard let nextYearBase = calendar.date(byAdding: .year, value: 1, to: referenceDate) else {
            return nil
        }
        
        return self.yearlyDate(for: rule, in: nextYearBase, calendar: calendar)
        
    }
    
    private func monthlyDate(for rule: LocalNotificationRecurrenceRule,
                             in monthReferenceDate: Date,
                             calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year, .month], from: monthReferenceDate)
        let requestedDay = rule.dayOfMonth ?? 1
        let dayRange = calendar.range(of: .day, in: .month, for: monthReferenceDate)
        let maxDay = dayRange?.count ?? requestedDay
        
        components.day = min(requestedDay, maxDay)
        components.hour = rule.hour
        components.minute = rule.minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
    private func yearlyDate(for rule: LocalNotificationRecurrenceRule,
                            in yearReferenceDate: Date,
                            calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year], from: yearReferenceDate)
        components.month = rule.month ?? 1
        
        guard let month = components.month,
              let year = components.year,
              let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))
        else {
            return nil
        }
        
        let requestedDay = rule.dayOfMonth ?? 1
        let dayRange = calendar.range(of: .day, in: .month, for: monthDate)
        let maxDay = dayRange?.count ?? requestedDay
        
        components.day = min(requestedDay, maxDay)
        components.hour = rule.hour
        components.minute = rule.minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
}

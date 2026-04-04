//
//  LocalNotificationRecurrenceCalculator.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

struct LocalNotificationRecurrenceCalculator {
    
    func nextOccurrence(for rule: LocalNotificationRecurrenceRule,
                        pattern: LocalNotificationSchedulePattern,
                        after referenceDate: Date,
                        calendar: Calendar = .autoupdatingCurrent) -> Date? {
        
        guard rule.isValid(for: pattern) else {
            return nil
        }
        
        switch pattern {
        case .interval:
            return nil
            
        case .anchored:
            return self.nextAnchoredOccurrence(
                for: rule,
                after: referenceDate,
                calendar: calendar
            )
            
        case .calendarType:
            return self.nextCalendarTypeOccurrence(
                for: rule,
                after: referenceDate,
                calendar: calendar
            )
        }
        
    }
    
    func nextOccurrenceAfterPrevious(for rule: LocalNotificationRecurrenceRule,
                                     pattern: LocalNotificationSchedulePattern,
                                     previousOccurrence: Date,
                                     calendar: Calendar = .autoupdatingCurrent) -> Date? {
        
        guard rule.isValid(for: pattern) else {
            return nil
        }
        
        switch pattern {
        case .interval:
            return nil
            
        case .anchored:
            return self.nextAnchoredOccurrenceAfterPrevious(
                for: rule,
                previousOccurrence: previousOccurrence,
                calendar: calendar
            )
            
        case .calendarType:
            return self.nextCalendarTypeOccurrenceAfterPrevious(
                for: rule,
                previousOccurrence: previousOccurrence,
                calendar: calendar
            )
        }
        
    }
    
    func nextOccurrences(for rule: LocalNotificationRecurrenceRule,
                         pattern: LocalNotificationSchedulePattern,
                         after referenceDate: Date,
                         count: Int,
                         calendar: Calendar = .autoupdatingCurrent) -> [Date] {
        
        guard count > 0 else {
            return []
        }
        
        var dates: [Date] = []
        var cursor = referenceDate
        
        while dates.count < count {
            
            let nextDate: Date?
            
            if let previousDate = dates.last {
                nextDate = self.nextOccurrenceAfterPrevious(
                    for: rule,
                    pattern: pattern,
                    previousOccurrence: previousDate,
                    calendar: calendar
                )
            }
            else {
                nextDate = self.nextOccurrence(
                    for: rule,
                    pattern: pattern,
                    after: cursor,
                    calendar: calendar
                )
            }
            
            guard let nextDate,
                  nextDate > cursor
            else {
                break
            }
            
            dates.append(nextDate)
            cursor = nextDate
            
        }
        
        return dates
        
    }
    
    func supportsRepeatingCalendarTrigger(for rule: LocalNotificationRecurrenceRule,
                                          pattern: LocalNotificationSchedulePattern,
                                          calendar: Calendar = .autoupdatingCurrent) -> Bool {
        
        guard rule.interval == 1,
              rule.isValid(for: pattern)
        else {
            return false
        }
        
        switch pattern {
        case .interval:
            return false
            
        case .anchored:
            return self.supportsAnchoredRepeatingTrigger(
                for: rule
            )
            
        case .calendarType:
            return self.supportsCalendarTypeRepeatingTrigger(
                for: rule,
                calendar: calendar
            )
        }
        
    }
    
    func repeatingDateComponents(for rule: LocalNotificationRecurrenceRule,
                                 pattern: LocalNotificationSchedulePattern,
                                 calendar: Calendar = .autoupdatingCurrent) -> DateComponents? {
        
        guard self.supportsRepeatingCalendarTrigger(
            for: rule,
            pattern: pattern,
            calendar: calendar
        ) else {
            return nil
        }
        
        var components = DateComponents()
        components.hour = rule.hour
        components.minute = rule.minute
        components.second = 0
        
        switch pattern {
        case .interval:
            return nil
            
        case .anchored:
            
            switch rule.cadence {
            case .day:
                return components
            
            case .week:
                guard let boundary = rule.anchoredBoundary else {
                    return nil
                }
                components.weekday = self.weekday(
                    for: boundary,
                    calendar: calendar
                )
                return components
            
            case .month:
                guard rule.anchoredBoundary == .start else {
                    return nil
                }
                components.day = 1
                return components
            
            case .year:
                guard let boundary = rule.anchoredBoundary else {
                    return nil
                }
                
                if boundary == .start {
                    components.month = 1
                    components.day = 1
                }
                else {
                    components.month = 12
                    components.day = 31
                }
                
                return components
            }
            
        case .calendarType:
            
            switch rule.calendarSelector {
            case .weekly(let weekdays):
                guard let weekday = Array(Set(weekdays)).first else {
                    return nil
                }
                components.weekday = weekday.rawValue
                return components
                
            case .monthly(let dayOfMonth):
                components.day = dayOfMonth
                return components
                
            case .yearly(let month, let dayOfMonth):
                components.month = month
                components.day = dayOfMonth
                return components
                
            case .none:
                return nil
            }
        }
        
    }
    
    private func nextAnchoredOccurrence(for rule: LocalNotificationRecurrenceRule,
                                        after referenceDate: Date,
                                        calendar: Calendar) -> Date? {
        
        switch rule.cadence {
        case .day:
            return self.nextDailyOccurrence(
                hour: rule.hour,
                minute: rule.minute,
                after: referenceDate,
                calendar: calendar
            )
            
        case .week:
            
            guard let boundary = rule.anchoredBoundary else {
                return nil
            }
            
            let weekday = self.weekday(
                for: boundary,
                calendar: calendar
            )
            
            return self.nextWeekdayOccurrence(
                weekday: weekday,
                hour: rule.hour,
                minute: rule.minute,
                after: referenceDate,
                calendar: calendar
            )
            
        case .month:
            
            guard let boundary = rule.anchoredBoundary,
                  let thisMonthCandidate = self.anchoredMonthDate(
                    for: boundary,
                    in: referenceDate,
                    hour: rule.hour,
                    minute: rule.minute,
                    calendar: calendar
                  )
            else {
                return nil
            }
            
            if thisMonthCandidate > referenceDate {
                return thisMonthCandidate
            }
            
            guard let nextMonth = calendar.date(byAdding: .month,
                                                value: 1,
                                                to: referenceDate)
            else {
                return nil
            }
            
            return self.anchoredMonthDate(
                for: boundary,
                in: nextMonth,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
            
        case .year:
            
            guard let boundary = rule.anchoredBoundary,
                  let thisYearCandidate = self.anchoredYearDate(
                    for: boundary,
                    in: referenceDate,
                    hour: rule.hour,
                    minute: rule.minute,
                    calendar: calendar
                  )
            else {
                return nil
            }
            
            if thisYearCandidate > referenceDate {
                return thisYearCandidate
            }
            
            guard let nextYear = calendar.date(byAdding: .year,
                                               value: 1,
                                               to: referenceDate)
            else {
                return nil
            }
            
            return self.anchoredYearDate(
                for: boundary,
                in: nextYear,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
        }
        
    }
    
    private func nextCalendarTypeOccurrence(for rule: LocalNotificationRecurrenceRule,
                                            after referenceDate: Date,
                                            calendar: Calendar) -> Date? {
        
        guard let selector = rule.calendarSelector else {
            return nil
        }
        
        switch selector {
        case .weekly(let weekdays):
            
            let normalizedWeekdays = Array(Set(weekdays))
            
            let nextDates = normalizedWeekdays.compactMap { weekday in
                self.nextWeekdayOccurrence(
                    weekday: weekday.rawValue,
                    hour: rule.hour,
                    minute: rule.minute,
                    after: referenceDate,
                    calendar: calendar
                )
            }
            
            return nextDates.min()
            
        case .monthly(let dayOfMonth):
            
            guard let thisMonthCandidate = self.monthlyDate(
                dayOfMonth: dayOfMonth,
                in: referenceDate,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            ) else {
                return nil
            }
            
            if thisMonthCandidate > referenceDate {
                return thisMonthCandidate
            }
            
            guard let nextMonth = calendar.date(byAdding: .month,
                                                value: 1,
                                                to: referenceDate)
            else {
                return nil
            }
            
            return self.monthlyDate(
                dayOfMonth: dayOfMonth,
                in: nextMonth,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
            
        case .yearly(let month, let dayOfMonth):
            
            guard let thisYearCandidate = self.yearlyDate(
                month: month,
                dayOfMonth: dayOfMonth,
                in: referenceDate,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            ) else {
                return nil
            }
            
            if thisYearCandidate > referenceDate {
                return thisYearCandidate
            }
            
            guard let nextYear = calendar.date(byAdding: .year,
                                               value: 1,
                                               to: referenceDate)
            else {
                return nil
            }
            
            return self.yearlyDate(
                month: month,
                dayOfMonth: dayOfMonth,
                in: nextYear,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
        }
        
    }
    
    private func nextAnchoredOccurrenceAfterPrevious(for rule: LocalNotificationRecurrenceRule,
                                                     previousOccurrence: Date,
                                                     calendar: Calendar) -> Date? {
        
        switch rule.cadence {
        case .day:
            return calendar.date(byAdding: .day,
                                 value: rule.interval,
                                 to: previousOccurrence)
            
        case .week:
            return calendar.date(byAdding: .weekOfYear,
                                 value: rule.interval,
                                 to: previousOccurrence)
            
        case .month:
            
            guard let boundary = rule.anchoredBoundary,
                  let nextMonthBase = calendar.date(byAdding: .month,
                                                    value: rule.interval,
                                                    to: previousOccurrence)
            else {
                return nil
            }
            
            return self.anchoredMonthDate(
                for: boundary,
                in: nextMonthBase,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
            
        case .year:
            
            guard let boundary = rule.anchoredBoundary,
                  let nextYearBase = calendar.date(byAdding: .year,
                                                   value: rule.interval,
                                                   to: previousOccurrence)
            else {
                return nil
            }
            
            return self.anchoredYearDate(
                for: boundary,
                in: nextYearBase,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
        }
        
    }
    
    private func nextCalendarTypeOccurrenceAfterPrevious(for rule: LocalNotificationRecurrenceRule,
                                                         previousOccurrence: Date,
                                                         calendar: Calendar) -> Date? {
        
        guard let selector = rule.calendarSelector else {
            return nil
        }
        
        switch selector {
        case .weekly(let weekdays):
            return self.nextWeeklyCalendarOccurrenceAfterPrevious(
                weekdays: weekdays,
                interval: rule.interval,
                hour: rule.hour,
                minute: rule.minute,
                previousOccurrence: previousOccurrence,
                calendar: calendar
            )
            
        case .monthly(let dayOfMonth):
            
            guard let nextMonthBase = calendar.date(byAdding: .month,
                                                    value: rule.interval,
                                                    to: previousOccurrence)
            else {
                return nil
            }
            
            return self.monthlyDate(
                dayOfMonth: dayOfMonth,
                in: nextMonthBase,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
            
        case .yearly(let month, let dayOfMonth):
            
            guard let nextYearBase = calendar.date(byAdding: .year,
                                                   value: rule.interval,
                                                   to: previousOccurrence)
            else {
                return nil
            }
            
            return self.yearlyDate(
                month: month,
                dayOfMonth: dayOfMonth,
                in: nextYearBase,
                hour: rule.hour,
                minute: rule.minute,
                calendar: calendar
            )
        }
        
    }
    
    private func nextWeeklyCalendarOccurrenceAfterPrevious(weekdays: [LocalNotificationWeekday],
                                                           interval: Int,
                                                           hour: Int,
                                                           minute: Int,
                                                           previousOccurrence: Date,
                                                           calendar: Calendar) -> Date? {
        
        let normalizedWeekdays = Array(Set(weekdays))
        
        guard !normalizedWeekdays.isEmpty else {
            return nil
        }
        
        let orderedWeekdays = normalizedWeekdays.sorted {
            self.weekdaySortValue(
                for: $0.rawValue,
                firstWeekday: calendar.firstWeekday
            ) < self.weekdaySortValue(
                for: $1.rawValue,
                firstWeekday: calendar.firstWeekday
            )
        }
        
        let previousWeekdayRawValue = calendar.component(.weekday,
                                                         from: previousOccurrence)
        
        guard let previousWeekday = LocalNotificationWeekday(rawValue: previousWeekdayRawValue),
              let previousIndex = orderedWeekdays.firstIndex(of: previousWeekday)
        else {
            return nil
        }
        
        if previousIndex + 1 < orderedWeekdays.count {
            
            return self.dateInSameWeek(
                as: previousOccurrence,
                weekday: orderedWeekdays[previousIndex + 1].rawValue,
                hour: hour,
                minute: minute,
                calendar: calendar
            )
            
        }
        
        guard let nextCycleWeekDate = calendar.date(byAdding: .weekOfYear,
                                                    value: interval,
                                                    to: previousOccurrence)
        else {
            return nil
        }
        
        return self.dateInSameWeek(
            as: nextCycleWeekDate,
            weekday: orderedWeekdays[0].rawValue,
            hour: hour,
            minute: minute,
            calendar: calendar
        )
        
    }
    
    private func nextDailyOccurrence(hour: Int,
                                     minute: Int,
                                     after referenceDate: Date,
                                     calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        guard let todayAtAnchor = calendar.date(from: components) else {
            return nil
        }
        
        if todayAtAnchor > referenceDate {
            return todayAtAnchor
        }
        
        return calendar.date(byAdding: .day,
                             value: 1,
                             to: todayAtAnchor)
        
    }
    
    private func nextWeekdayOccurrence(weekday: Int,
                                       hour: Int,
                                       minute: Int,
                                       after referenceDate: Date,
                                       calendar: Calendar) -> Date? {
        
        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.nextDate(
            after: referenceDate,
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
        
    }
    
    private func anchoredMonthDate(for boundary: LocalNotificationRecurrenceBoundary,
                                   in monthReferenceDate: Date,
                                   hour: Int,
                                   minute: Int,
                                   calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year, .month], from: monthReferenceDate)
        
        switch boundary {
        case .start:
            components.day = 1
        case .end:
            components.day = calendar.range(of: .day,
                                            in: .month,
                                            for: monthReferenceDate)?.count
        }
        
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
    private func anchoredYearDate(for boundary: LocalNotificationRecurrenceBoundary,
                                  in yearReferenceDate: Date,
                                  hour: Int,
                                  minute: Int,
                                  calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year], from: yearReferenceDate)
        
        switch boundary {
        case .start:
            components.month = 1
            components.day = 1
        case .end:
            components.month = 12
            components.day = 31
        }
        
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
    private func monthlyDate(dayOfMonth: Int,
                             in monthReferenceDate: Date,
                             hour: Int,
                             minute: Int,
                             calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year, .month], from: monthReferenceDate)
        
        let dayRange = calendar.range(of: .day,
                                      in: .month,
                                      for: monthReferenceDate)
        let maxDay = dayRange?.count ?? dayOfMonth
        
        components.day = min(dayOfMonth, maxDay)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
    private func yearlyDate(month: Int,
                            dayOfMonth: Int,
                            in yearReferenceDate: Date,
                            hour: Int,
                            minute: Int,
                            calendar: Calendar) -> Date? {
        
        var components = calendar.dateComponents([.year], from: yearReferenceDate)
        components.month = month
        
        guard let year = components.year,
              let monthDate = calendar.date(from: DateComponents(
                year: year,
                month: month,
                day: 1
              ))
        else {
            return nil
        }
        
        let maxDay = calendar.range(of: .day,
                                    in: .month,
                                    for: monthDate)?.count ?? dayOfMonth
        
        components.day = min(dayOfMonth, maxDay)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
    private func supportsAnchoredRepeatingTrigger(for rule: LocalNotificationRecurrenceRule) -> Bool {
        
        switch rule.cadence {
        case .day:
            return true
            
        case .week:
            return rule.anchoredBoundary != nil
            
        case .month:
            return rule.anchoredBoundary == .start
            
        case .year:
            return rule.anchoredBoundary != nil
        }
        
    }
    
    private func supportsCalendarTypeRepeatingTrigger(for rule: LocalNotificationRecurrenceRule,
                                                      calendar: Calendar) -> Bool {
        
        guard let selector = rule.calendarSelector else {
            return false
        }
        
        switch selector {
        case .weekly(let weekdays):
            return Array(Set(weekdays)).count == 1
            
        case .monthly(let dayOfMonth):
            return dayOfMonth <= 28
            
        case .yearly(let month, let dayOfMonth):
            guard let monthDate = calendar.date(from: DateComponents(
                year: 2025,
                month: month,
                day: 1
            )) else {
                return false
            }
            
            let maxDay = calendar.range(of: .day,
                                        in: .month,
                                        for: monthDate)?.count ?? dayOfMonth
            
            return dayOfMonth <= maxDay
        }
        
    }
    
    private func weekday(for boundary: LocalNotificationRecurrenceBoundary,
                         calendar: Calendar) -> Int {
        
        switch boundary {
        case .start:
            return calendar.firstWeekday
        case .end:
            return ((calendar.firstWeekday + 5) % 7) + 1
        }
        
    }
    
    private func weekdaySortValue(for weekday: Int,
                                  firstWeekday: Int) -> Int {
        return (weekday - firstWeekday + 7) % 7
    }
    
    private func dateInSameWeek(as referenceDate: Date,
                                weekday: Int,
                                hour: Int,
                                minute: Int,
                                calendar: Calendar) -> Date? {
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear,
                                                       for: referenceDate)
        else {
            return nil
        }
        
        let weekStartWeekday = calendar.component(.weekday,
                                                  from: weekInterval.start)
        let dayOffset = (weekday - weekStartWeekday + 7) % 7
        
        guard let targetDay = calendar.date(byAdding: .day,
                                            value: dayOffset,
                                            to: weekInterval.start)
        else {
            return nil
        }
        
        var components = calendar.dateComponents([.year, .month, .day],
                                                 from: targetDay)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components)
        
    }
    
}

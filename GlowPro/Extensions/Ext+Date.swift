//
//  Ext+Date.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/26/25.
//

import Foundation
import SwiftUI

extension Date {
    
    func preciseRelativeString(unitStyle: DateComponentsFormatter.UnitsStyle = .abbreviated,
                               allowedUnites: NSCalendar.Unit = [.minute, .hour, .day, .weekOfMonth, .month, .year],
                               maximumUnitCount: Int = 1) -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnites
        formatter.unitsStyle = unitStyle
        formatter.maximumUnitCount = maximumUnitCount
        
        let formattedDate = formatter.string(
            from: self,
            to: Date()
        )
        
        return formattedDate ?? "N/A"
        
    }
    
    func preciseFutureRelativeString(unitStyle: DateComponentsFormatter.UnitsStyle = .abbreviated,
                                     allowedUnites: NSCalendar.Unit = [.minute, .hour, .day, .weekOfMonth, .month, .year],
                                     maximumUnitCount: Int = 1) -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnites
        formatter.unitsStyle = unitStyle
        formatter.maximumUnitCount = maximumUnitCount
        
        let formattedDate = formatter.string(
            from: Date(),
            to: self
        )
        
        return formattedDate ?? "N/A"
        
    }
    
    func relativeDateStringWithOverride(_ override: String = "now") -> String {
        
        var formattedDate = self.preciseRelativeString()
        
        if formattedDate == "0m" {
            formattedDate = "now"
        }
        
        return formattedDate
        
    }
    
}

import Foundation
import SwiftUI

extension Date {
    
    /// Calendar-day relative string. Compares startOfDay to avoid "today" for a date on the next day.
    /// Examples: today/tomorrow/yesterday, "in 3 days", "2 days ago"
    func calendarDayRelativeString(nowOverride: String = "Today") -> String {
        
        var formattedDate = self.date.preciseFutureRelativeString(
            unitStyle: .full,
            allowedUnites: [.day]
        )
        
        formattedDate.removeAll(where: { $0 == "-"})
        
        if formattedDate == "0 days" { return nowOverride }
        if formattedDate == "1 day" { return "Yesterday" }
        if formattedDate == "-1 day" { return "Tomorrow" }
        
        return formattedDate.capitalized
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack {
            
            Text(Date().relativeDateStringWithOverride())
            Text(Date().dateByAdding(-1, .minute).dateByAdding(-1, .second).date.relativeDateStringWithOverride())
            Text(Date().dateByAdding(-1, .hour).date.relativeDateStringWithOverride())
            Text(Date().dateByAdding(-1, .day).date.relativeDateStringWithOverride())
            Text(Date().dateByAdding(-1, .month).date.relativeDateStringWithOverride())
            Text(Date().dateByAdding(-1, .year).date.relativeDateStringWithOverride())
            
            Rectangle()
                .fill(.clear)
                .frame(height: 32)

            Text(Date().date.calendarDayRelativeString())
            
            Text(Date().date
                .dateByAdding(-1, .day)
                .dateByAdding(-1, .second)
                .date
                .calendarDayRelativeString())
            
            Text(Date().date
                .dateByAdding(1, .day)
                .dateByAdding(1, .second)
                .date
                .calendarDayRelativeString())
            
            Text(Date().date
                .dateByAdding(2, .day)
                .dateByAdding(1, .second)
                .date
                .calendarDayRelativeString())
            
            Text(Date().date
                .dateByAdding(1, .month)
                .dateByAdding(1, .second)
                .date
                .calendarDayRelativeString())
            
            Text(Date().date
                .dateByAdding(1, .year)
                .date
                .calendarDayRelativeString())
            
        }
        .appFont(with: .HEADER_3)
        
    }
    
}

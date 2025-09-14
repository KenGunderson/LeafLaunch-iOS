//
//  Ext+Date.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/26/25.
//

import Foundation

extension DateComponentsFormatter {
    
    static let shortRelative: DateComponentsFormatter = {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day, .weekOfMonth, .month, .year]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
        
    }()
    
}

extension Date {
    
    func relativeDateString() -> String {
        
        var formattedDate = DateComponentsFormatter.shortRelative.string(
            from: self,
            to: Date()
        )
        
        if formattedDate == "0m" {
            formattedDate = "now"
        }
        
        return formattedDate ?? "N/A"
        
    }
    
}

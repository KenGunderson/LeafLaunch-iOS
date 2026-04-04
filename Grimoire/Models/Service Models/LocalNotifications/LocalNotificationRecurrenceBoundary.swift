//
//  LocalNotificationRecurrenceBoundary.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

enum LocalNotificationRecurrenceBoundary: String,
                                         CaseIterable,
                                         Hashable,
                                         Sendable {
    
    case start
    case end
    
    var displayName: String {
        switch self {
        case .start: return "Start"
        case .end: return "End"
        }
    }
    
}

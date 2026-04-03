//
//  LocalNotificationSchedulePattern.swift
//  Grimoire
//
//  Created by Codex on 4/3/26.
//

import Foundation

enum LocalNotificationSchedulePattern: String, CaseIterable, Hashable, Sendable {
    
    case interval
    case anchored
    
    var displayName: String {
        switch self {
        case .interval: return "Interval"
        case .anchored: return "Anchored"
        }
    }
    
}

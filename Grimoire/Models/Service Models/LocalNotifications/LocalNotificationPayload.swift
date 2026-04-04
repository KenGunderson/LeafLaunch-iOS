//
//  LocalNotificationPayload.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/3/26.
//

import Foundation

struct LocalNotificationPayload: Sendable {
    
    let identifier: String
    let request: LocalNotificationScheduleRequest
    
}

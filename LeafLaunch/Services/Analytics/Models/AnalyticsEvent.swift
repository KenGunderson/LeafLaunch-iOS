//
//  AnalyticsEvent.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import Foundation

protocol AnalyticsEvent {

    var eventType: EventType { get }
    var eventData: EventData { get }

}

extension AnalyticsEvent {

    var name: String {
        return self.eventData.name
    }

    var properties: [String: Any]? {
        return self.eventData.properties
    }

}

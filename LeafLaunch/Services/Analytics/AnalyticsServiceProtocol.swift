//
//  AnalyticsServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Observation
import Amplitude

protocol AnalyticsServiceProtocol: AnyObject, Sendable, Loggable {
        
    var currentUserId: CurrentValueSubject<String?, Never> { get }
    
    var sessionEvents: [EventData] { get }
    var sessionEventsPublisher: AnyPublisher<[EventData], Never> { get }
        
    func identifyUser(_ userId: String?)
    func setUserProperty(_ key: String, value: String)
    func track(_ app: AppEvent)
    func track(screen: ScreenEvent)
    func track(error: ErrorEvent)
    func clearSessionEvents()
    
    func logout()
    
}

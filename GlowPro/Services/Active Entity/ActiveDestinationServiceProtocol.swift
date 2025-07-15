//
//  ActiveDestinationServiceProtocol.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/25.
//

import Combine

protocol ActiveDestinationServiceProtocol: AnyObject, Sendable, Loggable {
    
    var activeDestination: ActiveDestination? { get }
    var activeDestinationPublisher: AnyPublisher<ActiveDestination?, Never> { get }
    
    func setActiveDestination(_ destination: ActiveDestination)
    func removeActiveDestination()
    func logout()
    
}

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
    
    var isOwner: Bool { get }
    var isManager: Bool { get }
    var isOwnerOrManager: Bool { get }
    
    var role: Role? { get }
    
    var business: Business? { get set }
    var businessId: String? { get set }
    
    var locationEmployee: LocationEmployee? { get set }
    
    func setActiveDestination(_ destination: ActiveDestination)
    func removeActiveDestination()
    func refresh()
    func logout()
    
}

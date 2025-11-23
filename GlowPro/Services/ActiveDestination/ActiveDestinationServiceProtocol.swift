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
    var isTemporaryLocationEmployee: Bool { get set }
    
    var isSubscribed: Bool { get }
    var canAddAnotherLocation: Bool { get }
    var canAddAnotherEmployee: Bool { get }
    var isMediaLimitReached: Bool { get }
    
    func setActiveDestination(_ destination: ActiveDestination)
    func removeActiveDestination()
    
    func setTemporaryLocationEmployee(_ locationId: String)
    func removeTemporaryLocationEmployee()
    
    func refresh()
    func logout()
    func getPaywallOverageContext() -> SubscriptionPaywallViewModel.Context
    
    
    func showLimitAlertIfNeeded(type: AppCardConfig.LimitType,
                                subscribeAction: @escaping () -> Void,
                                dismissAction: @escaping () -> Void) -> AppCardConfig.LimitReachhedAlert?
    
}

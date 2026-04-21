//
//  AppStoreSubscriptionServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/21/26.
//

import Foundation
import Combine

protocol AppStoreSubscriptionServiceProtocol: AnyObject, Sendable, Loggable {
    
    var subscriptionStatus: SubscriptionStatus { get }
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> { get }
    
    var products: [SubscriptionProduct] { get }
    var productsPublisher: AnyPublisher<[SubscriptionProduct], Never> { get }
    
    func configure() async throws
    func fetchProductOfferings() async throws -> [SubscriptionProduct]
    func subscribe(to product: SubscriptionProduct) async throws -> SubscriptionStatus
    func checkSubscriptionStatus() async throws -> SubscriptionStatus
    func restoreSubscriptions() async throws -> SubscriptionStatus
    func currentSubscriptionProduct() -> SubscriptionProduct?
    
}

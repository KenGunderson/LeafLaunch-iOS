//
//  AppStoreSubscriptionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/21/26.
//

import Foundation
import Combine
import StoreKit

final class AppStoreSubscriptionService: AppStoreSubscriptionServiceProtocol {
    
    internal let loggerName: String = "APP_STORE_SUBSCRIPTION_SERVICE"
    internal let loggerEmoji: String = "🛍️"
    
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .none
    var subscriptionStatusPublisher: AnyPublisher<SubscriptionStatus, Never> {
        return self.$subscriptionStatus.eraseToAnyPublisher()
    }
    
    @Published private(set) var products: [SubscriptionProduct] = []
    var productsPublisher: AnyPublisher<[SubscriptionProduct], Never> {
        return self.$products.eraseToAnyPublisher()
    }
    
    private let productIdentifiers: Set<String>
    private var storeProductsById: [String: Product] = [:]
    private var transactionListenerTask: Task<Void, Never>?
    private var didConfigure = false
    
    init(productIdentifiers: Set<String>) {
        
        self.productIdentifiers = productIdentifiers
        self.logInit()
        
    }
    
    deinit {
        
        self.transactionListenerTask?.cancel()
        self.logDeinit()
        
    }
    
    func configure() async throws {
        
        guard !self.productIdentifiers.isEmpty else {
            throw AppStoreSubscriptionError.productIdentifiersMissing
        }
        
        if self.transactionListenerTask == nil {
            
            self.transactionListenerTask = Task { [weak self] in
                await self?.listenForTransactions()
            }
            
        }
        
        try await self.fetchProducts()
        try await self.updateSubscriptionStatus()
        self.didConfigure = true
        
        self.log(message: "Configured with \(self.productIdentifiers.count) product identifiers")
        
    }
    
    func fetchProductOfferings() async throws -> [SubscriptionProduct] {
        
        if !self.didConfigure || self.products.isEmpty {
            try await self.configure()
        }
        
        return self.products
        
    }
    
    func subscribe(to product: SubscriptionProduct) async throws -> SubscriptionStatus {
        
        if !self.didConfigure {
            try await self.configure()
        }
        
        let storeProduct = try await self.resolveStoreProduct(for: product.id)
        let result = try await storeProduct.purchase()
        
        switch result {
        case .success(let verification):
            
            let transaction = try self.verify(verification)
            await transaction.finish()
            try await self.updateSubscriptionStatus()
            
            self.log(message: "Subscribe success for product id: \(product.id)")
            return self.subscriptionStatus
            
        case .userCancelled: throw AppStoreSubscriptionError.userCancelled
        case .pending: throw AppStoreSubscriptionError.purchasePending
        @unknown default: throw AppStoreSubscriptionError.unknownPurchaseResult
        }
        
    }
    
    func checkSubscriptionStatus() async throws -> SubscriptionStatus {
        
        if !self.didConfigure {
            try await self.configure()
        }
        
        try await self.updateSubscriptionStatus()
        self.log(message: "Received subscription status: \(self.subscriptionStatus)")
        
        return self.subscriptionStatus
        
    }
    
    func restoreSubscriptions() async throws -> SubscriptionStatus {
        
        if !self.didConfigure {
            try await self.configure()
        }
        
        try await AppStore.sync()
        try await self.updateSubscriptionStatus()
        
        self.log(message: "Restore completed with status: \(self.subscriptionStatus)")
        
        return self.subscriptionStatus
        
    }
    
    func currentSubscriptionProduct() -> SubscriptionProduct? {
        
        guard case .active(let productId, _) = self.subscriptionStatus else {
            return nil
        }
        
        return self.products.first(where: { $0.id == productId })
        
    }
    
    private func fetchProducts() async throws {
        
        let requestedProductIds = Array(self.productIdentifiers).sorted()
        let fetchedProducts = try await Product.products(for: requestedProductIds)
        
        let subscriptionProducts = fetchedProducts
            .filter { $0.type == .autoRenewable }
            .sorted { lhs, rhs in
                lhs.price < rhs.price
            }
        
        let mappedProducts = subscriptionProducts.map {
            SubscriptionProduct(
                id: $0.id,
                title: $0.displayName,
                description: $0.description,
                price: $0.price,
                displayPrice: $0.displayPrice
            )
        }
        
        let mappedStoreProductsById = Dictionary(uniqueKeysWithValues: subscriptionProducts.map {
            ($0.id, $0)
        })
        
        await MainActor.run {
            
            self.products = mappedProducts
            self.storeProductsById = mappedStoreProductsById
            
        }
        
        if mappedProducts.isEmpty {
            self.log(message: "No auto-renewable products were found for the configured identifiers")
        } else {
            let productNames = mappedProducts.map({ $0.title }).joined(separator: ", ")
            self.log(message: "Fetched products: \(productNames)")
        }
        
    }
    
    private func listenForTransactions() async {
        
        for await result in Transaction.updates {
            
            do {
                
                let transaction = try self.verify(result)
                guard transaction.productType == .autoRenewable else { continue }
                
                await transaction.finish()
                try await self.updateSubscriptionStatus()
                
                self.log(message: "Handled transaction update for product id: \(transaction.productID)")
                
            } catch {
                
                self.logError(
                    title: "StoreKit Transaction Update Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
    }
    
    private func updateSubscriptionStatus() async throws {
        
        var bestActiveEntitlement: Transaction?
        var latestExpiredDate: Date?
        
        for await result in Transaction.currentEntitlements {
            
            do {
                
                let transaction = try self.verify(result)
                guard transaction.productType == .autoRenewable else { continue }
                
                if transaction.revocationDate != nil {
                    continue
                }
                
                if let expirationDate = transaction.expirationDate,
                   expirationDate <= Date() {
                    
                    latestExpiredDate = self.maxDate(
                        left: latestExpiredDate,
                        right: expirationDate
                    )
                    
                    continue
                }
                
                bestActiveEntitlement = self.bestTransaction(
                    current: bestActiveEntitlement,
                    candidate: transaction
                )
                
            } catch {
                
                self.logError(
                    title: "StoreKit Entitlement Verification Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
        if latestExpiredDate == nil {
            latestExpiredDate = await self.latestExpiredDateFromHistory()
        }
        
        await MainActor.run {
            
            if let bestActiveEntitlement {
                self.subscriptionStatus = .active(
                    productId: bestActiveEntitlement.productID,
                    expiryDate: bestActiveEntitlement.expirationDate
                )
            } else if let latestExpiredDate {
                self.subscriptionStatus = .expired(expiryDate: latestExpiredDate)
            } else {
                self.subscriptionStatus = .none
            }
            
        }
        
    }
    
    private func latestExpiredDateFromHistory() async -> Date? {
        
        var latestExpiredDate: Date?
        
        for productId in self.productIdentifiers {
            
            guard let latestTransactionResult = await Transaction.latest(for: productId) else {
                continue
            }
            
            do {
                
                let transaction = try self.verify(latestTransactionResult)
                guard transaction.productType == .autoRenewable else { continue }
                
                if let expirationDate = transaction.expirationDate,
                   expirationDate <= Date() {
                    
                    latestExpiredDate = self.maxDate(
                        left: latestExpiredDate,
                        right: expirationDate
                    )
                    
                }
                
            } catch {
                
                self.logError(
                    title: "StoreKit History Verification Error",
                    message: error.getMessageForError()
                )
                
            }
            
        }
        
        return latestExpiredDate
        
    }
    
    private func resolveStoreProduct(for productId: String) async throws -> Product {
        
        if let product = self.storeProductsById[productId] {
            return product
        }
        
        try await self.fetchProducts()
        
        if let product = self.storeProductsById[productId] {
            return product
        }
        
        throw AppStoreSubscriptionError.productNotFound(productId: productId)
        
    }
    
    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        
        switch result {
        case .verified(let safe): return safe
        case .unverified: throw AppStoreSubscriptionError.failedVerification
        }
        
    }
    
    private func bestTransaction(current: Transaction?, candidate: Transaction) -> Transaction {
        
        guard let current else {
            return candidate
        }
        
        let currentDate = current.expirationDate ?? current.purchaseDate
        let candidateDate = candidate.expirationDate ?? candidate.purchaseDate
        
        return (candidateDate >= currentDate) ? candidate : current
        
    }
    
    private func maxDate(left: Date?, right: Date?) -> Date? {
        
        switch (left, right) {
        case (.some(let leftDate), .some(let rightDate)): return max(leftDate, rightDate)
        case (.some(let leftDate), .none): return leftDate
        case (.none, .some(let rightDate)): return rightDate
        case (.none, .none): return nil
        }
        
    }
    
}

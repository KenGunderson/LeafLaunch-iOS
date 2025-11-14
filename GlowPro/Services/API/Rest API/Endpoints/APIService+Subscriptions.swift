//
//  APIService+Subscriptions.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/14/25.
//

extension APIService {

    func getAllSubscriptionProducts() async throws -> [StripeSubscriptionProduct] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .subscriptions("products"))
            )
            
            let result: [StripeSubscriptionProduct] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getStripePaymentLink(businessId: String) async throws -> StripePaymentLink {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .subscriptions("\(businessId)/stripe-link"))
            )
            
            let result: StripePaymentLink = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func subscribe(businessId: String,
                   productId: String,
                   setupIntentId: String) async throws -> StripeSubscription {
        
        let parameters: [String: Any] = [
            "business_id": businessId,
            "product_id": productId,
            "setup_intent_id": setupIntentId
        ]
        .compact()
        
        do {
            
            let data = try await buildRequest(
                method: .post,
                apiPath: .init(path: .subscriptions("")),
                parameters: parameters
            )
            
            let result: StripeSubscription = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
}

//
//  StripeSubscriptionProduct.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/17/25.
//

struct StripeSubscriptionProduct: Identifiable, Codable, Hashable {
    
    struct Metadata: Hashable, Codable {
        
        let totalNumberOfEmployees: Int?
        let totalNumberOfLocations: Int?
        let totalNumberOfMedia: Int?
        
        private enum CodingKeys: String, CodingKey {
            
            case totalNumberOfEmployees = "total_number_of_employees"
            case totalNumberOfLocations = "total_number_of_locations"
            case totalNumberOfMedia = "total_number_of_media"
            
        }
        
        init(totalNumberOfEmployees: Int? = 0,
             totalNumberOfLocations: Int? = 0,
             totalNumberOfMedia: Int? = 0) {
            
            self.totalNumberOfEmployees = totalNumberOfEmployees
            self.totalNumberOfLocations = totalNumberOfLocations
            self.totalNumberOfMedia = totalNumberOfMedia
            
        }
        
    }
    
    struct Price: Codable, Hashable {
        
        let id: String
        let amount: Int
        let interval: String
        
    }
  
    let id: String
    let name: String
    let description: String?
    let defaultPriceId: String?
    var prices: [Price]
    let active: Bool
    let metadata: Metadata?
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case description
        case defaultPriceId = "default_price_id"
        case prices
        case active
        case metadata
        
    }
    
}

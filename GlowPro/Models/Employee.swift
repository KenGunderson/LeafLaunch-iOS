//
//  Employee.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation
 
struct Employee: Identifiable,
                 Equatable,
                 Hashable,
                 Codable,
                 Mockable {
    
    let id: String
    let businessId: String
    let locationId: String
    let userId: String
    let name: String
    let email: String
    let phone: String
    let role: Role
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case locationId = "location_id"
        case userId = "user_id"
        case name
        case email
        case phone
        case role
        
    }
    
}

extension Employee {
    
    static func DUMMY_DATA() -> Employee {
        
        return .init(
            id: UUID().uuidString,
            businessId: MockModels.ID.business1,
            locationId: MockModels.ID.location1,
            userId: MockModels.ID.user1,
            name: "Juan Employee",
            email: "juan@me.com",
            phone: "8185225755",
            role: .employee
        )
        
    }
    
}


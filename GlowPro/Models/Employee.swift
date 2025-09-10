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
    let userId: String
    let name: String
    let email: String
    let phoneNumber: String
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case userId = "user_id"
        case name
        case email
        case phoneNumber = "phone_number"
        
    }
    
}

extension Employee {
    
    static func DUMMY_DATA() -> Employee {
        
        return .init(
            id: UUID().uuidString,
            businessId: MockModels.ID.business1,
            userId: MockModels.ID.user1,
            name: "Juan Employee",
            email: "juan@me.com",
            phoneNumber: "8185225755",
        )
        
    }
    
}


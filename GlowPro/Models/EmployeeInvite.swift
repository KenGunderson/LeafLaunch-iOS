//
//  EmployeeInvite.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/4/25.
//

import Foundation

struct EmployeeInvite: Identifiable, Hashable, Codable, Mockable {
    
    let id: String
    let name: String
    let email: String
    let businessId: String
    let businessName: String
    let locationIds: [String]
    let role: Role?
    
    init(id: String,
         name: String,
         email: String,
         businessId: String,
         businessName: String,
         locationIds: [String] = [],
         role: Role? = nil) {
        
        self.id = id
        self.name = name
        self.email = email
        self.businessId = businessId
        self.businessName = businessName
        self.locationIds = locationIds
        self.role = role
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case email
        case businessId = "business_id"
        case businessName = "business_name"
        case locationIds = "location_ids"
        case role
        
    }
    
}

extension EmployeeInvite {
    
    static func DUMMY_DATA() -> EmployeeInvite {
        
        return .init(
            id: UUID().uuidString,
            name: "Sako Hovaguimian",
            email: "sako@hovaguimian.com",
            businessId: "1",
            businessName: "My Awesome Business"
        )
        
    }
    
}

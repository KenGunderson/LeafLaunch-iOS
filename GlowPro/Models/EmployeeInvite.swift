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
    let businessName: String
    let locations: [Location] = []
    let role: Role?
    
    init(id: String,
         name: String,
         email: String,
         businessName: String) {
        
        self.id = id
        self.name = name
        self.email = email
        self.businessName = businessName
        self.role = nil
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case email
        case businessName = "business_name"
        case locations
        case role
        
    }
    
}

extension EmployeeInvite {
    
    static func DUMMY_DATA() -> EmployeeInvite {
        
        return .init(
            id: UUID().uuidString,
            name: "Sako Hovaguimian",
            email: "sako@hovaguimian.com",
            businessName: "My Awesome Business"
        )
        
    }
    
}

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
    let location: Location
    
    init(id: String,
         name: String,
         email: String,
         businessName: String,
         location: Location) {
        
        self.id = id
        self.name = name
        self.email = email
        self.businessName = businessName
        self.location = location
        
    }
    
}

extension EmployeeInvite {
    
    static func DUMMY_DATA() -> EmployeeInvite {
        
        return .init(
            id: UUID().uuidString,
            name: "Sako Hovaguimian",
            email: "sako@hovaguimian.com",
            businessName: "My Awesome Business",
            location: .DUMMY_DATA()
        )
        
    }
    
}

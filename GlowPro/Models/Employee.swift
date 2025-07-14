//
//  Employee.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation
 
struct Employee: Identifiable,
                 Codable,
                 Mockable {
    
    let id: String
    let businessId: String
    let name: String
    let email: String
    let phone: String
    let role: Role
    
}

extension Employee {
    
    static func DUMMY_DATA() -> Employee {
        
        return .init(
            id: UUID().uuidString,
            businessId: "123",
            name: "Juan Employee",
            email: "juan@me.com",
            phone: "8185225755",
            role: .employee
        )
        
    }
    
}


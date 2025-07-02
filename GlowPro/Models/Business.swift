//
//  Business.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

struct Business: Identifiable,
                 Codable,
                 Mockable {
    
    let id: String
    let name: String
    let email: String?
    let phoneNumber: String?
    let address: Address?
    let owner: GPUser
    
}

extension Business {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: UUID().uuidString,
            name: "The Hallal Guys",
            email: "hallalguy@gmail.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            owner: .DUMMY_DATA()
        )
        
    }
    
}

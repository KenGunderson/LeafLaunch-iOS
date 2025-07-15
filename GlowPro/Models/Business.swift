//
//  Business.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

struct Business: Identifiable,
                 Equatable,
                 Hashable,
                 Codable,
                 Mockable {
    
    let id: String
    let name: String
    let email: String?
    let phoneNumber: String?
    let address: Address?
    let locations: [Location]
    let owner: GPUser
    
    var isOwner: Bool {
        return self.id == self.owner.id
    }
    
}

extension Business {
    
    static func DUMMY_DATA() -> Self {
        
        let id = UUID().uuidString
        
        return .init(
            id: id,
            name: "The Hallal Guys",
            email: "hallalguy@gmail.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            locations: [],
            owner: .DUMMY_DATA()
        )
        
    }
    
}

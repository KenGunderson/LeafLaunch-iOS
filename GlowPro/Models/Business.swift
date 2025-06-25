//
//  Business.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation

struct Business: Codable, Mockable {
    
    struct Address: Codable {
        
        let street: String
        let street2: String?
        let city: String
        let state: String
        let zip: String
        
    }
    
    let name: String
    let email: String?
    let phoneNumber: String?
    let address: Address?
    let owner: GPUser
    
}

extension Business {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            name: "The Hallal Guys",
            email: "hallalguy@gmail.com",
            phoneNumber: "818-522-5755",
            address: .init(
                street: "502 East Oceanfront",
                street2: nil,
                city: "Newport Beach",
                state: "CA",
                zip: "92661"
            ),
            owner: .DUMMY_DATA()
        )
        
    }
    
}

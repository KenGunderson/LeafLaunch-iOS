//
//  Address.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation

struct Address: Codable,
                Mockable {
    
    let street: String
    let street2: String?
    let city: String
    let state: String
    let zip: String
    
}

extension Address {
    
    static func DUMMY_DATA() -> Address {
        return .init(
            street: "502 East Oceanfront",
            street2: nil,
            city: "Newport Beach",
            state: "CA",
            zip: "92661"
        )
    }
    
}
